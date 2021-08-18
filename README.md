# Wikicheck

A small goloang service to search wikipedia page view stats.

## Local Development

You'll need to install an up-to-date version of:
* [Docker](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/install)
* [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

These are compatiable for macOS and 64-bit Linux.

You will need GNUMake.

You can get a list of useful Make commands using `make help`

You can get started by running `make up`.

`make docker_insertdata` will download the data for the database and insert it.

You can view the fancy website at `http://localhost:8080`

If you make changes to the code you can deploy and test the new changes locally
with `make redeploy`.

You can also run this locally, if you do so it will use the SQLite database.
You'll also need to make sure you have Go Lang setup and installed.

You'll need to download a pageviews tar from [Wikipedia](https://dumps.wikimedia.org/other/pageviews/)
and import it into the SQLite database. There is atool to help with importing but
it takes a while.

e.g.
```shell
wget --quiet http://dumps.wikimedia.org/other/pageviews/2018/2018-11pageviews-20181116-000000.gz -O page_views.data.gz
gunzip page_views.data.gz
go run tools/import/main.go page_views.data
```

## Deploying a new container

Make sure your AWS credentials are in the file `.env` like so:

```
export AWS_ACCESS_KEY_ID=AKISKI3930SJ
export AWS_SECRET_ACCESS_KEY=abcdefasjsdpoopefmklfdsmlkfdsmlfdmklfdmklfd
```

To deploy a new version of the software run `make app_push`.

This will build the container, push it to ECR and redeploy the service.


## How Do I...?

### Run a terraform plan or apply?

We are using a Terraform wrapper called Terragrunt.

To run a Terraform plan or apply use `make tf-plan` or `make tf-apply` in the
root of this repo.

### Where is the application?

The application is written in GoLang and is mostly* under `internal/`

### Compiling/checking changes

You can test your changes in docker-compose. The Makefile wraps these commands.

You can get started by running `make up`.

`make docker_insertdata` will download the data for the database and insert it.

`make redeploy` will stop the container, rebuild your application and bring it
back up.

### Where is the Terraform?

The module used is `techtest` and this is located under
`deployments/modules/techtest`

### Where is the database schema defined?

We use an ORM (GORM) to create and manage the schema. It's definition is in
`internal/schema/schema.go` 

### How is this run in production?

We are running this in a container in AWS ECS Fargate. It connects to a MySQL
RDS instance.

### Login to the AWS Console?

Use your user credentials at https://sf-tech-test.signin.aws.amazon.com/console
