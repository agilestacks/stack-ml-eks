.DEFAULT_GOAL := deploy

kubectl := kubectl --context="$(HUB_DOMAIN_NAME)"

deploy:
	$(kubectl) get -f profile.yaml || \
		$(kubectl) apply -f profile.yaml
	$(kubectl) get -f namespace.yaml || \
		$(kubectl) apply -f namespace.yaml

drop-finalizers/%:
	- $(kubectl) get -f $* -o json \
		| jq '. | del(.spec.finalizers)' \
		| $(kubectl) replace -f -

undeploy: drop-finalizers/profile.yaml 
undeploy: drop-finalizers/namespace.yaml
undeploy:
	$(kubectl) delete -f profile.yaml
	$(kubectl) delete -f namespace.yaml

.IGNORE: undeploy
.PHONY: deploy undeploy
