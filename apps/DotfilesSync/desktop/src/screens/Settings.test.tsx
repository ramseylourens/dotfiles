import { fireEvent, render, waitFor } from '@testing-library/react-native';
import React from 'react';
import { Provider } from 'react-redux';
import { ThemeProvider } from 'src/contexts/ThemeContext';
import { Settings } from 'src/screens/Settings';
import * as presentationMode from 'src/services/presentationMode';
import { store } from 'src/store';
import { Platform } from 'react-native';

describe('Settings', () => {
    beforeEach(() => {
        jest.spyOn(presentationMode, 'getPresentationMode').mockResolvedValue('window');
        jest.spyOn(presentationMode, 'setPresentationMode').mockResolvedValue();
        jest.spyOn(presentationMode, 'supportsTrayMode').mockReturnValue(true);
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    const pageTree = (
        <Provider store={store}>
            <ThemeProvider>
                <Settings />
            </ThemeProvider>
        </Provider>
    );

    it('Should match snapshot', async () => {
        const page = render(pageTree);
        await waitFor(() => expect(page.getByText('Window')).toBeTruthy());
        expect(page.toJSON()).toMatchSnapshot();
    });

    it('changes and persists the selected presentation mode', async () => {
        const page = render(pageTree);
        await waitFor(() => expect(page.getByText('System Tray')).toBeTruthy());
        fireEvent.press(page.getByText('System Tray'));
        await waitFor(() => expect(presentationMode.setPresentationMode).toHaveBeenCalledWith('tray'));
    });

    it('defines labels for macOS and Windows', async () => {
        const select = jest.spyOn(Platform, 'select');
        const page = render(pageTree);
        await waitFor(() => expect(page.getByText('Window')).toBeTruthy());
        expect(select).toHaveBeenCalledWith(expect.objectContaining({
            macos: 'home.text.platform.macos',
            windows: 'home.text.platform.windows',
        }));
        select.mockRestore();
    });
});
