var Q = require('q');
var _ = require('lodash');
var path = require('path');
var fs = require('fs');
var less = require('less');

// Compile a less file into a css
function renderLESS(input, output) {
    var d = Q.defer();
    var lessinput = fs.readFileSync(input, {
        encoding: 'utf-8'
    });

    less.render(lessinput, {
        paths: [
            path.dirname(input)
        ],
        filename: path.basename(input),
        compress: true
    }, function (e, out) {
        if (e) return d.reject(e);

        fs.writeFileSync(output, out.css);
        d.resolve();
    });

    return d.promise;
}

module.exports = {
    hooks: {
        // Compile less as CSS
        init: function() {
            var book = this;

            var styles = book.config.get('styles');

            return _.reduce(styles, function(prev, filename, type) {
                return prev.then(function() {
                    if (path.extname(filename).toLowerCase() != '.less') return;

                    book.log.info.ln('compile less file: ', filename);

                    // Temporary CSS file
                    var tmpfile = type+'-'+Date.now()+'.css';

                    // Replace config
                    book.config.set('styles.'+type, tmpfile);

                    return renderLESS(
                        book.resolve(filename),
                        path.resolve(book.options.output, tmpfile)
                    );
                });
            }, Q());
        }
    }
};
