# Dapla local stack

Configuration for a local runtime environment that ties services together
to form a complete working example sandbox.


## Getting started

Look bellow in the **Additional Config** section, and make sure you have completed the **Maven config** and **Secrets** steps to avoid errors completing the **Make** steps.

### Make

In your terminal, navigate to the `localstack` folder.
Make sure you have pulled down all related Dapla repositories from GitHub:

```sh
make update-all
```

Then, generate some necessary keys:

```sh
make generate-keys
```

Then, build all the things:
```sh
make build-all
```

...and finally run all the things:
```sh
make start-all
```

If you only need to start services (without Spark, Zeppelin, etc), you can go:
```sh
make start-services
```

If you simply want to start a subset of containers, you can specify them explicitly, like so:
```sh
docker-compose up dapla-auth-dataset-service postgres db-admin
```

If you're working with the `dapla-spark-plugin` and want to see your latest changes applied
to your running environment without having to rebuild everything:
```sh
make spark-plugin-redploy
```
You can further customize this with the `skipPseudo=true` and/or `skipPlugin=true` params.

### JupyterLab and Keycloak credentials

To use JupyterLab, you will need credentials in the local Keycloak system. The credentials are stored in the file `keycloak_ssb_realm.json`. This command will open your local Keycloak dashboard in your browser:
```
make open-keycloak
```
The username and password are ´admin´.
You might have a user to your name from before (check `keycloak_ssb_realm.json`), in that case you might still need to create a password. If not, create a new user and a password.

At this point you can run
```
make start-jupyter-exploration-with-console
make open-jupyter
```
...and log on to jupyter using the personal username and password you created with Keycloak.

### Setup Linked Data Store

All GSIM schemas for the service can be generated with:
```
make generate-exploration-schemas
```
You will find the generated files in `localstack/docker/exploration/jsonschemas` and `localstack/docker/exploration/graphqlschemas`.

If you wish to import some example domains you can run:
```
make run-scenario s=import-exploration-examples
```

The same thing can be done for "concept" schemas if you swap `exploration` with `concept` in the scripts and output locations.

## Additional config

### Maven config

Some artifacts that this stack relies on are only available from SSBs internal Nexus (Nexus is a Package Index server software). Make sure your Maven `settings.xml` contains an appropriate profile with credentials for Nexus. You can get a settings file from the Dapla team. It can be placed at `~/.m2/settings.xml`.

### Secrets

In order to run the tests for the full stack you will need to have a service account file available in your environment.
Ask a friend to get hold of this.

- The project _dapla-spark-plugin_ needs a service account key file placed under`/secret/gcs_sa_test.json`.
This is needed to build the docker image and to run integration tests against a GCS bucket. Ask a Dapla member to get a copy of this file.

It might be necessary to run these Google Cloud SDK terminal commands:
```
gcloud components install docker-credential-gcr
gcloud auth configure-docker
```

### Intellij

When pulling down repositories inside `dapla-project` intellij might not recognize these as separate repositories. To 
make intellij recognize sub repos go to "Settings -> Version Control" and then add any repos listed as "Unregistered".

### GCR in addition too DockerHub

In order to pull Docker images from `eu.gcr.io` you need to run `gcloud auth configure-docker eu.gcr.io` and you are 
good to go.

This requires an installation of the Google Cloud SDK, and to pull, your user to be authorized against Statistics Norway 
image registry. If you are not, you can always build them locally yourself, all frontend repositories are open on GitHub.

## Gotchas

### Docker memory

Serving "the world" requires memory. If you e.g. experience that "everything" hangs or becomes
sluggy when running a command from Zeppelin, it might be because your Docker runtime needs more
memory. You can configure the memory settings from "Docker preferences -> Advanced".


## Make targets

There are many other convenience make tasks. Type `make help` to see the full list:
```
update-all                                    Update all repos from github (checkout/pull)
build-all                                     Build all
build-all-docker                              Build all docker containers
build-all-mvn                                 Build all maven projects
start-all                                     Start all docker containers
start-all-with-console                        Start all docker containers with output to existing console
start-all-recreate                            Recreate and start docker containers even if their configuration and image haven't changed
start-services                                Start all services (excluding spark, etc)
stop-all                                      Stop and remove all docker containers
stop-services                                 Stop all services (excluding spark, etc)
spark-plugin-redeploy                         Build and redeploy the spark plugin and/or associated libs
spark-interpreter-restart                     Restart the Zeppelin Spark interpreter
open-db-admin                                 Open a DB admin tool in your browser
open-zeppelin                                 Open Zeppelin in your browser
open-jupyter                                  Open Jupyter in your browser
open-hadoop-cluster                           Open Hadoop cluster browser
open-hadoop-hdfs                              Open Hadoop nameserver/dataserver
open-dapla-metadata-explorer                  Open Dapla Metadata Explorer in your browser
open-dapla-workbench                          Open Dapla Workbench in your browser
open-dapla-user-access-admin                  Open Dapla User Access Admin in your browser
print-local-changes                           Show a brief summary of local changes
generate-concept-schemas                      Generate schemas from RAML files for setting up Linked Data Store for Concept
generate-exploration-schemas                  Generate schemas from RAML files for setting up Linked Data Store for the entire GSIM model
generate-keys                                 Generate keys for catalog, metadata-distributor, data-access
```

## Services

See the [docker-compose](https://github.com/statisticsnorway/dapla-project/blob/master/localstack/docker-compose.yml) file for a list of al the services.
