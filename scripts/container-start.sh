set -e

/usr/local/bundle/bin/bundle install
/usr/local/bundle/bin/bundle exec jekyll serve --watch --port 4000 &
echo Jekyll running on port 4000