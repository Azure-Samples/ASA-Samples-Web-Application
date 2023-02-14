package com.microsoft.azure.simpletodo.repository;

import java.util.List;

import com.microsoft.azure.simpletodo.model.TodoItem;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TodoItemRepository extends PagingAndSortingRepository<TodoItem, String> {

    List<TodoItem> findByListId(String listId);

    List<TodoItem> findByListId(String listId, Pageable pageable);

    List<TodoItem> findByListIdAndState(String listId, String state, Pageable pageable);
}
