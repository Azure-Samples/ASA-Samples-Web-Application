# Run the app in localhost

## Prerequisites

- Java 17 or later

## Steps to run the app in localhost

1. Build sample project.

    ```shell
    ./mvnw clean package -DskipTests
    ```

2. Run sample project.

    ```shell
    java -jar web/target/simple-todo-web-0.0.1-SNAPSHOT.jar
    ```

3. Access `http://localhost:8080` by browser, you will see a page like this:

> ![web.png](../assets/web.png)