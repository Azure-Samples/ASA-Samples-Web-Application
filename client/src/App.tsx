import React, {useReducer, FC, useState} from 'react';
import { HashRouter } from 'react-router-dom';
import Layout from './layout/layout';
import './App.css';
import { DarkTheme } from './ux/theme';
import { AppContext, ApplicationState, getDefaultState } from './models/applicationState';
import appReducer from './reducers';
import { TodoContext } from './components/todoContext';
import { initializeIcons } from '@fluentui/react/lib/Icons';
import { ThemeProvider } from '@fluentui/react';
import Telemetry from './components/telemetry';

export const App: FC = () => {
  const [listId, setListId] = useState("")
  const [itemId, setItemId] = useState("")

  const defaultState: ApplicationState = getDefaultState();
  const [applicationState, dispatch] = useReducer(appReducer, defaultState);
  const updateListId = (newListId: string)=> {
      setListId(newListId);
  }
  const updateItemId = (newItemId: string)=> {
      setItemId(newItemId);
  }
  const initialContext: AppContext = { state: applicationState, dispatch: dispatch, listId, updateListId, itemId, updateItemId }

  initializeIcons();

  return (
    <ThemeProvider applyTo="body" theme={DarkTheme}>
      <TodoContext.Provider value={initialContext}>
        <HashRouter>
          <Telemetry>
            <Layout />
          </Telemetry>
        </HashRouter>
      </TodoContext.Provider>
    </ThemeProvider>
  );
};
