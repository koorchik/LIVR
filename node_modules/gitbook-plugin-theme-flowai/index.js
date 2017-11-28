
module.exports = {
    hooks: {
        config: function(config) {
            config.styles = config.styles || config.pluginsConfig['theme-flowai'].styles;

            return config;
        }
    }
};
