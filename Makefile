#Run this makefile after creating the service principal and editing the secrets and configmap details

trivy:
	kubectl apply -f azure-storage-secret.yaml
	kubectl apply -f trivy-client-configmap.yaml
	kubectl apply -f service-principal-secret.yaml
	kubectl apply -f k8s-cronjob.yaml