.DEFAULT_GOAL := deploy

export NAME        ?= ml
export DOMAIN_NAME ?= dev.cloud-account-name.superhub.io

STATE_BUCKET ?= agilestacks.cloud-account-name.superhub.io
STATE_REGION ?= us-east-2

# CLI mode parameters compatibility
export HUB_STACK_NAME   := $(NAME)
export HUB_DOMAIN_NAME  := $(DOMAIN_NAME)
export HUB_STATE_BUCKET := $(STATE_BUCKET)
export HUB_STATE_REGION := $(STATE_REGION)

STACK_NAME ?= ml

STORAGE_KIND    ?= s3
STATE_CONTAINER ?= agilestacks

STATE_PATH := $(DOMAIN_NAME)/hub/$(STACK_NAME)-$(NAME)/hub
ELABORATE_FILE_FS := hub.yaml.elaborate
ifeq (az,$(STORAGE_KIND))
ELABORATE_FILE_CLOUD := $(STORAGE_KIND)://$(STATE_BUCKET)/$(STATE_CONTAINER)/$(STATE_PATH).elaborate
else
ELABORATE_FILE_CLOUD := $(STORAGE_KIND)://$(STATE_BUCKET)/$(STATE_PATH).elaborate
endif
ELABORATE_FILES := $(ELABORATE_FILE_FS),$(ELABORATE_FILE_CLOUD)

STATE_FILE_FS := hub.yaml.state
ifeq (az,$(STORAGE_KIND))
STATE_FILE_CLOUD := $(STORAGE_KIND)://$(STATE_BUCKET)/$(STATE_CONTAINER)/$(STATE_PATH).state
else
STATE_FILE_CLOUD := $(STORAGE_KIND)://$(STATE_BUCKET)/$(STATE_PATH).state
endif
STATE_FILES := $(STATE_FILE_FS),$(STATE_FILE_CLOUD)

TEMPLATE_PARAMS ?= params/template.yaml
STACK_PARAMS    ?= params/$(DOMAIN_NAME).yaml

PLATFORM_PROVIDES    += aws-marketplace
PLATFORM_STATE_FILES ?=

COMPONENT :=
VERB :=

RESTORE_BUNDLE_FILE ?= restore-bundles/$(DOMAIN_NAME).yaml
RESTORE_PARAMS_FILE ?= restore-params.yaml

HUB_OPTS ?=

hub    ?= hub -d
aws    ?= aws --region $(STATE_REGION)
gsutil ?= gsutil
az     ?= az

space :=
space +=
comma := ,

ifdef HUB_TOKEN
ifdef HUB_ENVIRONMENT
ifdef HUB_STACK_INSTANCE
HUB_LIFECYCLE_OPTS ?= --hub-environment "$(HUB_ENVIRONMENT)" --hub-stack-instance "$(HUB_STACK_INSTANCE)" \
	--hub-sync --hub-sync-skip-parameters-and-oplog
endif
endif
endif

ifeq (,$(wildcard $(RESTORE_BUNDLE_FILE)))
$(RESTORE_PARAMS_FILE):
	@echo --- > $(RESTORE_PARAMS_FILE)
else
$(RESTORE_PARAMS_FILE): $(RESTORE_BUNDLE_FILE)
	$(hub) backup unbundle $(RESTORE_BUNDLE_FILE) -o $(RESTORE_PARAMS_FILE)
endif

$(ELABORATE_FILE_FS): hub.yaml $(TEMPLATE_PARAMS) $(STACK_PARAMS) $(RESTORE_PARAMS_FILE) params.yaml pull
	$(hub) elaborate \
		hub.yaml params.yaml $(TEMPLATE_PARAMS) $(STACK_PARAMS) $(RESTORE_PARAMS_FILE) \
		$(if $(PLATFORM_PROVIDES),-p $(subst $(space),$(comma),$(PLATFORM_PROVIDES)),) \
		$(if $(PLATFORM_STATE_FILES),-s $(PLATFORM_STATE_FILES),) \
		$(HUB_OPTS) \
		-o $(ELABORATE_FILES)

elaborate:
	-rm -f $(ELABORATE_FILE_FS)
	$(MAKE) $(ELABORATE_FILE_FS)
.PHONY: elaborate

pull:
	$(hub) pull hub.yaml
.PHONY: pull

explain:
	$(hub) explain $(ELABORATE_FILES) $(STATE_FILES) $(HUB_OPTS) --color -r | less -R
.PHONY: explain

ifneq ($(PLATFORM_STATE_FILES),)
kubeconfig:
	$(hub) kubeconfig --switch-kube-context $(HUB_OPTS) $(PLATFORM_STATE_FILES)
.PHONY: kubeconfig
endif

COMPONENT_LIST := $(if $(COMPONENT),-c $(COMPONENT),)

deploy: $(ELABORATE_FILE_FS)
	$(hub) deploy $(ELABORATE_FILES) -s $(STATE_FILES) $(HUB_LIFECYCLE_OPTS) $(HUB_OPTS) \
		$(COMPONENT_LIST)
.PHONY: deploy

undeploy: $(ELABORATE_FILE_FS)
	$(hub) --force undeploy $(ELABORATE_FILES) -s $(STATE_FILES) $(HUB_LIFECYCLE_OPTS) $(HUB_OPTS) \
		$(COMPONENT_LIST)
.PHONY: undeploy

sync:
	$(hub) api instance sync $(if $(PLATFORM_STATE_FILES),$(NAME)@,)$(DOMAIN_NAME) \
		-s $(STATE_FILES) $(HUB_OPTS)
.PHONY: sync

ifneq ($(COMPONENT),)
invoke: $(ELABORATE_FILE_FS)
	$(eval , := ,)
	$(eval WORDS := $(subst $(,), ,$(COMPONENT)))
	@$(foreach c,$(WORDS), \
		$(hub) invoke $(c) $(VERB) -m $(ELABORATE_FILES) -s $(STATE_FILES) $(HUB_OPTS);)
.PHONY: invoke
endif

backup: $(ELABORATE_FILE_FS)
	$(hub) backup create --json $(ELABORATE_FILES) -s $(STATE_FILES) -o "$(BACKUP_BUNDLE_FILE)" -c "$(COMPONENTS)"
	@echo '--- backup bundle'
	@zcat $(BACKUP_BUNDLE_FILE)
	@echo
.PHONY: backup

remove_s3_state:
	-$(aws) s3 rm $(STATE_FILE_CLOUD)
.PHONY: remove_s3_state

remove_gs_state:
	-$(gsutil) rm $(STATE_FILE_CLOUD)
.PHONY: remove_gs_state

remove_az_state:
	-$(az) storage blob delete --account-name $(STATE_BUCKET) --container-name $(STATE_CONTAINER) --name $(STATE_PATH)
.PHONY: remove_az_state

clean: remove_$(STORAGE_KIND)_state
	@rm -f hub.yaml.state hub.yaml.elaborate
.PHONY: clean
