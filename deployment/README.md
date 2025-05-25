docker build --no-cache -t aksdevacrnewrelic.azurecr.io/frontend:1 -f Dockerfile .
docker build --no-cache -t aksdevacrnewrelic.azurecr.io/backend:1 -f Dockerfile .

docker push aksdevacrnewrelic.azurecr.io/frontend:1
docker push aksdevacrnewrelic.azurecr.io/backend:1