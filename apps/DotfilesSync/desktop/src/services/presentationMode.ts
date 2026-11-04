import AsyncStorage from '@react-native-async-storage/async-storage';
import { NativeModules, Platform } from 'react-native';

export type PresentationMode = 'window' | 'tray';

const storageKey = 'dotfiles.presentationMode';

type DesktopShell = {
    getPresentationMode: () => Promise<PresentationMode>;
    setPresentationMode: (mode: PresentationMode) => Promise<void>;
    platform: 'darwin' | 'linux' | 'win32';
};

declare global {
    interface Window {
        dotfilesShell?: DesktopShell;
    }
}

type NativePresentationMode = {
    getMode: () => Promise<PresentationMode>;
    setMode: (mode: PresentationMode) => Promise<void>;
};

function nativePresentationMode(): NativePresentationMode | undefined {
    return NativeModules.PresentationMode as NativePresentationMode | undefined;
}

export async function getPresentationMode(): Promise<PresentationMode> {
    if (Platform.OS === 'web' && window.dotfilesShell) {
        return window.dotfilesShell.getPresentationMode();
    }

    const nativeModule = nativePresentationMode();
    if (nativeModule) {
        return nativeModule.getMode();
    }

    const stored = await AsyncStorage.getItem(storageKey);
    return stored === 'tray' ? 'tray' : 'window';
}

export async function setPresentationMode(mode: PresentationMode): Promise<void> {
    if (Platform.OS === 'web' && window.dotfilesShell) {
        await window.dotfilesShell.setPresentationMode(mode);
        await AsyncStorage.setItem(storageKey, mode);
        return;
    }

    const nativeModule = nativePresentationMode();
    if (nativeModule) {
        await nativeModule.setMode(mode);
    }
    await AsyncStorage.setItem(storageKey, mode);
}

export function supportsTrayMode(): boolean {
    if (Platform.OS === 'web') {
        return Boolean(window.dotfilesShell);
    }

    return Boolean(nativePresentationMode());
}
