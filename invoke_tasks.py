from canvass_deployer import tasks
from invoke import Collection


CONFIG = {
    "azure_container_repo_name": "canvass-trivy",
    "kubernetes_deployment_name": [
        "trivy",
    ],  # Has to be a list of strings.
}

ns = Collection.from_module(tasks, config={"project_config": CONFIG})