/** Link prefixes/domains for deep linking */
const linkingPrefixes = [
  'https://reactnativestarter.app',
  'dotfiles-sync://',
];

// FIXME: Better type
export const linking = {
  prefixes: linkingPrefixes,
  config: {
    screens: {
      HomeStack: {
        path: "home",
        initialRouteName: "Home",
        screens: {
          Home: "/",
          Profile: {
            path: "user/:id",
          },
        },
      },
      Settings: "settings",
    },
  },
};
