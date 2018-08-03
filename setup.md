# Setup

## Run the MongoDB container

```bash
docker run --name mongo4 -d -p 27017:27017 mongo:4.0
```

> Note the container is named _mongo4_

## Build the monolith app

Make sure you change to the `monolith-app` directory!

```bash
cd monolith-app
docker build -t YOURNAME/demo-monolith .
```

## Run the Application

This runs the monolith application

```bash
docker run --name monolith -i -p 3000:3000 -d YOURNAME/demo-monolith
```

Observer the results

```bash
docker ps
# Note the id of the container and replace YOUR_CONTAINER_ID
docker logs YOUR_CONTAINER_ID
```

What went wrong? The connection in the code wants "localhost" which it assumed was there. But it is on a different "machine" altogether.

If you look at `monolith-app\app.js`, you will find a line `var mongoDB = process.env.MONGO_URL1 || 'mongodb://localhost:27017/appDemo1';`. This line enables us to override the URL that the app will use to connect to Mongo.

Docker RUN lets you pass in environment variables when you start the container. Next we will pass the address of  the Mongo container to the app container. But first, we need to figure out what it is.

```bash
docker network inspect bridge
```

Note the entry that resembles:

```json
"ConfigOnly": false,
        "Containers": {
            "a1d983e85d83cfd817804f4ce8bb307e1f1bfde05757ecf72a71c52896825a07": {
                "Name": "mongo4",
                "EndpointID": "...",
                "MacAddress": "...",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            ...
```

This network lists __172.17.0.2__ as the IP of the Mongo container.

```bash
docker run --name monolith --env MONGO_URL1="mongodb://172.17.0.2:27017/appDemo1" -i -p 3000:3000 -d YOURNAME/demo-monolith
```

Check the logs again.

```bash
docker ps
# Note the id of the container and replace YOUR_CONTAINER_ID
docker logs YOUR_CONTAINER_ID
```

Notice there still is no connection. To let our app access the Mongo server by name, we can add a link.
Docker RUN will link the Mongo container to our app container, and allow our application to refer to the Mongo container simply by its container name.

```bash
docker run -i -p 3000:3000 --env MONGO_URL1="mongodb://mongo4:27017/appDemo1" --link mongo4 -d YOURNAME/demo-monolith
```
