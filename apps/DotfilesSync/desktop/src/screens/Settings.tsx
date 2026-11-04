import React from 'react';
import { Platform, Pressable, View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { getPresentationMode, PresentationMode, setPresentationMode, supportsTrayMode } from 'src/services/presentationMode';
import { useThemeSystem } from 'src/contexts/ThemeContext';
import { useI18n } from 'src/i18n/hooks';
import { useEffect, useState } from 'react';

const styles = StyleSheet.create({
    container: {
        flex: 1, justifyContent: 'center', alignItems: 'center',
    },
    theme: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 40,
    },
    languages: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 20,
    },
    action: {
        paddingHorizontal: 12,
        paddingVertical: 8,
        marginRight: 8,
        borderRadius: 4,
    },
    actionText: {
        fontSize: 16,
    },
    footer: {
        marginTop: 40
    },
    presentation: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 20,
    },
    unavailable: {
        maxWidth: 460,
        textAlign: 'center',
    },
    disabledAction: {
        opacity: 0.5,
    },
})

export const Settings = () => {
    const { t, changeLanguage } = useI18n();
    const { theme, toggleTheme } = useThemeSystem();
    const [presentationMode, setPresentationModeState] = useState<PresentationMode>('window');
    const [isLoadingMode, setIsLoadingMode] = useState(true);
    const [modeError, setModeError] = useState('');
    const trayModeSupported = supportsTrayMode();
    const desktopPlatform = Platform.OS === 'web' ? window.dotfilesShell?.platform : Platform.OS;
    const isMacOS = desktopPlatform === 'macos' || desktopPlatform === 'darwin';
    const windowModeLabel = isMacOS
        ? 'Dock'
        : desktopPlatform === 'win32' || desktopPlatform === 'windows'
            ? 'Taskbar'
            : 'Window';
    const trayModeLabel = isMacOS ? 'Menu Bar' : 'System Tray';

    useEffect(() => {
        getPresentationMode()
            .then(setPresentationModeState)
            .catch((error: unknown) => setModeError(String(error)))
            .finally(() => setIsLoadingMode(false));
    }, []);

    const updatePresentationMode = async (mode: PresentationMode) => {
        setModeError('');
        try {
            await setPresentationMode(mode);
            setPresentationModeState(mode);
        } catch (error) {
            setModeError(String(error));
        }
    };

    const platform = Platform.select({
        web: t('home.text.platform.web'),
        macos: t('home.text.platform.macos'),
        windows: t('home.text.platform.windows'),
    });

    return (
        <View style={[styles.container, { backgroundColor: theme.palette.background }]}>
            <View style={styles.theme}>
                <Text style={{ color: theme.palette.onBackground }}>Theme: </Text>
                <Pressable
                    accessibilityRole="button"
                    onPress={toggleTheme}
                    style={styles.action}
                >
                    <Text style={[styles.actionText, { color: theme.palette.onBackground }]}>
                        {String(theme.paletteName === 'light' ? t('Light') : t('Dark'))}
                    </Text>
                </Pressable>
            </View>
            <View style={styles.languages}>
                <Pressable accessibilityRole="button" onPress={() => changeLanguage('en')} style={styles.action}>
                    <Text style={[styles.actionText, { color: theme.palette.onBackground }]}>{String(t('english'))}</Text>
                </Pressable>
                <Pressable accessibilityRole="button" onPress={() => changeLanguage('vi')} style={styles.action}>
                    <Text style={[styles.actionText, { color: theme.palette.onBackground }]}>{String(t('vietnamese'))}</Text>
                </Pressable>
            </View>
            <View style={styles.presentation}>
                <Text style={{ color: theme.palette.onBackground }}>App appearance: </Text>
                {isLoadingMode ? (
                    <ActivityIndicator />
                ) : (
                    <>
                        <Pressable
                            accessibilityRole="button"
                            accessibilityState={{ selected: presentationMode === 'window' }}
                            onPress={() => updatePresentationMode('window')}
                            style={styles.action}
                        >
                            <Text style={[styles.actionText, { color: theme.palette.onBackground }]}>
                                {windowModeLabel}
                            </Text>
                        </Pressable>
                        <Pressable
                            accessibilityRole="button"
                            accessibilityState={{ selected: presentationMode === 'tray' }}
                            disabled={!trayModeSupported}
                            onPress={() => updatePresentationMode('tray')}
                            style={[styles.action, !trayModeSupported && styles.disabledAction]}
                        >
                            <Text style={[styles.actionText, { color: theme.palette.onBackground }]}>
                                {trayModeLabel}
                            </Text>
                        </Pressable>
                    </>
                )}
            </View>
            {!trayModeSupported && (
                <Text style={[styles.unavailable, { color: theme.palette.onBackground }]}>
                    Mini-app mode is unavailable in this build.
                </Text>
            )}
            {modeError !== '' && (
                <Text accessibilityRole="alert" style={[styles.unavailable, { color: theme.palette.onBackground }]}>
                    Could not change app appearance: {modeError}
                </Text>
            )}
            <Text style={[styles.footer, { color: theme.palette.onBackground }]} accessibilityRole="header" aria-level="2">
                {platform}
            </Text>
        </View>
    );
}
