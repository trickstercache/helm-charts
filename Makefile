TRICKSTER_ORG ?= trickstercache
IMAGE_REPO ?= ghcr.io/$(TRICKSTER_ORG)/trickster
IMAGE_TAG ?= main

.PHONY: uninstall
uninstall:
	helm uninstall trickster || true

.PHONY: install
install: uninstall
	helm upgrade trickster charts/trickster-v2 --install --set image.repository=$(IMAGE_REPO) --set image.tag=$(IMAGE_TAG) --set service.serviceNodePort=31209 --set service.type=NodePort

install-with-pvc: uninstall
	helm upgrade trickster charts/trickster-v2 --install --set image.repository=$(IMAGE_REPO) --set image.tag=$(IMAGE_TAG) --set service.serviceNodePort=31209 --set service.type=NodePort --set persistentVolume.enabled=true --set persistentVolume.storageClass=openebs-hostpath

install-with-ingress: uninstall
	helm upgrade trickster charts/trickster-v2 --install --set image.repository=$(IMAGE_REPO) --set image.tag=$(IMAGE_TAG)  --set ingress.enabled=true

.PHONY: query
query:
	open http://localhost:31209/query

query-ingress:
	open http://trickster.local/query
	# open http://trickster.local/query

.PHONY: logs
logs:
	kubectl logs -f deploy/trickster-trickster-v2

.PHONY: install-prom
install-prom:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install prometheus prometheus-community/prometheus

.PHONY: install-nginx
install-nginx:
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

.PHONY: install-openebs
install-openebs:
	helm repo add openebs https://openebs.github.io/charts
	helm repo update
	helm install openebs --namespace openebs openebs/openebs --create-namespace

.PHONY: setup-kind
setup-kind:
	kind delete cluster --name trickster || true
	kind create cluster --config kind-config.yaml
	$(MAKE) install-nginx install-prom install-openebs

.PHONY: package
package:
	helm package charts/trickster-v2 --destination charts

GITHUB_REPOSITORY_OWNER ?= $(TRICKSTER_ORG)
GHCR_REPO ?= ghcr.io/$(GITHUB_REPOSITORY_OWNER)/charts
.PHONY: publish
publish: package
	@for pkg in charts/*.tgz; do \
		if [[ "$$pkg" =~ "charts/trickster-1" ]]; then \
			continue; \
		fi; \
		echo "Publishing $${pkg} to $(GHCR_REPO)"; \
		helm push "$${pkg}" "oci://$(GHCR_REPO)"; \
	done
