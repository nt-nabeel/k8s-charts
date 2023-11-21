up:
	@sh -c "cd charts/claim && helm dependency update"
	@sh -c "cd charts/claim && helm lint ."
	@sh -c "cd charts/claim && helm upgrade --install --debug --namespace test --create-namespace test ."

down:
	@sh -c "helm uninstall --namespace test test"

publish-services:
	@sh -c "cd charts/application && helm lint ."
	@sh -c "cd charts/rds && helm lint ."
	@sh -c "cd charts/nosql && helm lint ."
	@sh -c "cd charts/file-storage && helm lint ."
	@sh -c "cd charts/rabbitmq && helm lint ."
	@sh -c "cd charts/redis && helm lint ."
	@sh -c "helm package charts/application --destination packages"
	@sh -c "helm package charts/rds --destination packages"
	@sh -c "helm package charts/nosql --destination packages"
	# @sh -c "helm package charts/file-storage --destination packages"
	@sh -c "helm package charts/rabbitmq --destination packages"
	@sh -c "helm package charts/redis --destination packages"
	@sh -c "helm repo index --url https://nt-nabeel.github.io/k8s-charts/packages/ packages"
	@sh -c "mv packages/index.yaml index.yaml"
	@sh -c "git commit --all --amend --reuse-message HEAD"
	@sh -c "git push --force origin main"

publish-claim:
	@sh -c "cd charts/claim && helm lint . && helm dependency update"
	@sh -c "helm package charts/claim --destination packages"
	@sh -c "helm repo index --url https://nt-nabeel.github.io/k8s-charts/packages/ packages"
	@sh -c "mv packages/index.yaml index.yaml"
	@sh -c "git commit --all --amend --reuse-message HEAD"
	@sh -c "git push --force origin main"

update-repo:
	@sh -c "if helm repo list 2>/dev/null | grep -q \"nt-nabeel\"; then helm repo remove nt-nabeel; fi"
	@sh -c "helm repo add nt-nabeel https://nt-nabeel.github.io/k8s-charts/"
	@sh -c "helm repo update"
