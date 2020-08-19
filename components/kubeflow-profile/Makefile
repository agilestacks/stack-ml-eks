.DEFAULT_GOAL := deploy

kubectl := kubectl --context="$(HUB_DOMAIN_NAME)"

deploy:
	$(kubectl) get -f namespace.yaml \
		|| $(kubectl) apply -f namespace.yaml
	$(kubectl) -n "$(KF_NAMESPACE)" get -f profile.yaml \
		|| $(kubectl) -n "$(KF_NAMESPACE)" apply -f profile.yaml

drop-finalizers/%:
	- $(kubectl) get -f $* -o json > /dev/null 2>&1 \
		| jq '. | del(.metadata.finalizers) | del(.spec.finalizers)' \
		| $(kubectl) replace -f -

cleanup-all undeploy: NAMESPACE:=$(notdir $(shell $(kubectl) get -f namespace.yaml -o name 2>/dev/null))
cleanup-all: RESOURCES:=$(shell $(kubectl) api-resources --namespaced=true -o name | xargs)
cleanup-all:
	echo "Cleaning up dangling resources in $(NAMESPACE)..."
	for r in $(RESOURCES); do \
		$(kubectl) delete $$r --all -n $(NAMESPACE) > /dev/null 2>&1; \
	done

undeploy: drop-finalizers/profile.yaml 
undeploy: cleanup-all
	$(kubectl) -n "$(KF_NAMESPACE)" delete -f profile.yaml --force
	if test -n "$(NAMESPACE)"; then \
		$(kubectl) get namespace "$(NAMESPACE)" -o json > /dev/null 2>&1 \
			| jq '. | del(.spec.finalizers)' \
			| $(kubectl) replace --raw "/api/v1/namespaces/$(NAMESPACE)/finalize" -f - ; \
		$(kubectl) delete namespace "$(NAMESPACE)" --force; \
	fi

.SILENT: cleanup-all
.PHONY: deploy undeploy cleanup cleanup-all
.IGNORE: undeploy cleanup cleanup-all
# TODO: remove line below after completiion of a full test iteration 
.IGNORE: deploy
