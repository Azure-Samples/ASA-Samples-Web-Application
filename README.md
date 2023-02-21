# Azure Spring Apps Sample - Simple Todo App

## Prerequisites

- Java 17 or later
- Maven
- Docker

## Run The App

1. Prepare necessary environment variable.

    ```shell
    export POSTGRES_PASSWORD=mysecretpassword
    ```

2. Start a PostgreSQL docker container.

    ```shell
    docker run \
        --name todo-postgres \
        -e POSTGRES_DB=postgres \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
        -d \
        -p 5432:5432 \
        postgres:11.19-alpine
    ```

3. Build sample project.

    ```shell
    mvn clean package -DskipTests
    ```

4. Run sample project.

    ```shell
    mvn spring-boot:run -f web/pom.xml
    ```

5. Access `http://localhost:8080` by browser.
