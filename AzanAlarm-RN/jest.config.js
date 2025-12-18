module.exports = {
  preset: 'react-native',
  moduleDirectories: ['node_modules', 'src'],
  setupFiles: ['./jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|@react-navigation|react-native-mmkv|adhan)/)',
  ],
};

