'use strict';

var path = require('path');
var gulp = require('gulp');
var conf = require('./conf');

var ngdocs = require('gulp-ngdocs');


gulp.task('docs', function () {
    var options = {
        scripts: [
            'bower/angular/angular.min.js',
            'bower/angular-animate/angular-animate.min.js'
        ],
        title: 'Repository Angular Docs',
        html5Mode: false
    };

    return gulp.src(path.join(conf.paths.src, 'app/**/*.js'))
        .pipe(ngdocs.process(options))
        .pipe(gulp.dest('./docs'));
});
