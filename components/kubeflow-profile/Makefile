.DEFAULT_GOAL := deploy

kubectl := kubectl --context="$(HUB_DOMAIN_NAME)"

deploy:
	$(kubectl) get -f profile.yaml   || $(kubectl) apply -f profile.yaml
	$(kubectl) get -f namespace.yaml || $(kubectl) apply -f namespace.yaml

drop-finalizers/%:
	- $(kubectl) get -f $* -o json \
		| jq '. | del(.metadata.finalizers) | del(.spec.finalizers)' \
		| $(kubectl) replace -f -

cleanup cleanup-all: NAMESPACE:=$(notdir $(shell $(kubectl) get -f namespace.yaml -o name))
cleanup-all: RESOURCES:=$(shell $(kubectl) api-resources --namespaced=true -o name | xargs)
cleanup-all:
	echo "Cleaning up resources in $(NAMESPACE)"
	for r in $(RESOURCES); do \
		printf "* Deleting $$r...\t"; \
		$(kubectl) delete $$r --all -n $(NAMESPACE); \
	done

cleanup: RESOURCES:=$(shell $(kubectl) get all -n $(NAMESPACE) -o name | xargs)
cleanup:
	echo "Cleaning up resources in $(NAMESPACE)"
	test -z "$(RESOURCES)" || \
		$(kubectl) delete -n $(NAMESPACE) $(shell echo $(RESOURCES) | tr -s '[:blank:]' ',')

undeploy: drop-finalizers/profile.yaml 
undeploy: drop-finalizers/namespace.yaml
undeploy: cleanup
	$(kubectl) delete -f namespace.yaml
	$(kubectl) delete -f profile.yaml

.SILENT: cleanup-all
.IGNORE: undeploy cleanup cleanup-all
.PHONY: deploy undeploy cleanup cleanup-all
