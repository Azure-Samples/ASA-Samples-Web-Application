package com.microsoft.azure.simpletodo.model;

import com.fasterxml.jackson.annotation.JsonValue;

import javax.annotation.Generated;

import com.fasterxml.jackson.annotation.JsonCreator;

/**
 * Gets or Sets TodoState
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen")
public enum TodoState {

  TODO("todo"),

  INPROGRESS("inprogress"),

  DONE("done");

  private String value;

  TodoState(String value) {
    this.value = value;
  }

  @JsonValue
  public String getValue() {
    return value;
  }

  @Override
  public String toString() {
    return String.valueOf(value);
  }

  @JsonCreator
  public static TodoState fromValue(String value) {
    for (TodoState b : TodoState.values()) {
      if (b.value.equals(value)) {
        return b;
      }
    }
    throw new IllegalArgumentException("Unexpected value '" + value + "'");
  }
}

