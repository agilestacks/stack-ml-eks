.DEFAULT_GOAL := deploy

kubectl := kubectl --context="$(HUB_DOMAIN_NAME)"

deploy:
	$(kubectl) get -f namespace.yaml \
		|| $(kubectl) apply -f namespace.yaml
	$(kubectl) -n (KF_NAMESPACE) get -f profile.yaml \
		|| $(kubectl) -n (KF_NAMESPACE) apply -f profile.yaml

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
	$(kubectl) -n (KF_NAMESPACE) delete -f profile.yaml
	$(kubectl) delete -f namespace.yaml

.SILENT: cleanup-all
.IGNORE: undeploy cleanup cleanup-all
.PHONY: deploy undeploy cleanup cleanup-all
