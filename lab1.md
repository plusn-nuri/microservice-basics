# Lab I

This lab is designed to study some of the aspects involved in building microservices.
It explores basic docker and docker-compose features.

## Baseline

In this part, we want to run a monolithic application, backed by a single database.

### Run Database Container

The monolithic application requires a database to store its data. A databse is commonly orchestrated as a separate resource due to it's stateful and durable nature.

In this lab, we'll run the database in a container so that we don't need to install or manage a full blown database.

```bash
docker run --name mongo4 -d -p 27017:27017 mongo:4.0
```

> Note the container is named _mongo4_

### Run Monolithic App

The monolithic application renders a page showing a shopping cart and a user this shopping cart belongs to.

First, let's run the application to ensure it works.

> **This application relies on Node V10+. If you do not have node on your host machine, or can't run version 10, you may skip this part.**

```bash
# change directory to the monolithic app
cd ./monolith-app
# install library dependencies using npm
npm install
# run the monolithic application
npm start
```

This runs the application. This web applicaiton runs on TCP port 3000. Open a browser to <http://localhost:3000/> and check to ensure the application is running.

## Dockerize Monolith

To take advantage of flexible infrastructure and enable continuous integration, we're going to package the monolithic application.

This is a common "brown field" technique: simply packaging an existing code base so it can be launched in a cloud environment or on modern dev-ops on premises.

> Make sure you change directory to the `monolith-app` directory!

```bash
cd monolith-app
docker build -t YOURNAME/demo-monolith .
```

### Run the dockerized pplication

Runnint the monolithic application is no different from running any "official" container. All we need to take care of is exposing the port so that we can browse the web applciation in the container.

```bash
docker run --name monolith -i -p 3000:3000 -d YOURNAME/demo-monolith
```

This runs the container you built, specifying:

- Container will be named _monolith_
- TCP port 3000 on the host will be mapped to port 3000 in the container

### Troubleshooting

To see if there are any errors, we can check the logs. Run `docker ps` to find the id of your container.

```bash
docker ps
# Note the id of the container and replace YOUR_CONTAINER_ID
docker logs YOUR_CONTAINER_ID
```

What went wrong? The connection in the code wants "localhost" which it assumed was running on the same machine. But docker containers isolate the processes from each other. It might as well be on a different "machine" altogether.

If you look at `monolith-app\app.js`, you will find a line `var mongoDB = process.env.MONGO_URL1 || 'mongodb://localhost:27017/appDemo1';`. This line enables us to override the URL that the app will use to connect to Mongo.

Docker RUN lets you pass in environment variables when you start the container. Next we will pass the address of  the Mongo container to the app container. But first, we need to figure out what it is.

```bash
docker network inspect bridge
```

Look for the container that runs our database.

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

The IPv4Address  lists __172.17.0.2__ as the IP of the Mongo container. Your IP may differ, so note the IP that YOUR container is assigned.

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
Docker RUN will link the application container to the Mongo container, and allow our application to refer to the Mongo container simply by its container name.

```bash
docker run -i -p 3000:3000 --env MONGO_URL1="mongodb://mongo4:27017/appDemo1" --link mongo4 -d YOURNAME/demo-monolith
```

Check the logs to ensure the connection is now successful.

Point a browser to <http://localhost:3000/> and ensure the application renders a page showing a shopping cart.