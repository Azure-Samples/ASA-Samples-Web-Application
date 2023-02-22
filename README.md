# Azure Spring Apps Sample - Simple Todo App

## Prerequisites

- Java 17 or later

## Run The App

1. Build sample project.

    ```shell
    ./mvnw clean package -DskipTests
    ```

2. Run sample project.

    ```shell
    ./mvnw spring-boot:run -f web/pom.xml
    ```

3. Access `http://localhost:8080` by browser, you will see a page like this:

> ![web.png](./assets/web.png)
