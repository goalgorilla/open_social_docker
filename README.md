# Docker images for the Open Social distrbution

Repository for Docker images for the Open Social distribution. Check [drupal.org](https://www.drupal.org/project/social)

- [Open Social Distribution Github repo](https://github.com/goalgorilla/open_social)
- [Open Social Distribution issue queue](https://www.drupal.org/project/issues/social).
- [Open Social development repo] (https://github.com/goalgorilla/drupal_social)
- [Docker Hub](https://hub.docker.com/r/goalgorilla/open_social_docker/)
- [Composer template](https://github.com/goalgorilla/social_template)

Tags:
latest: production image
ci: contains development packages in composer.json
dev: contains development packages and xdebug
cron: contains cron and runs cron script

# Issues
For any issues with the platform we kindly ask you to use the [drupal.org](http://www.drupal.org/project/issues/social) issue queue. This way we can centralise all the information and make the feedback available for other users for documentation purposes. Next to giving people the credit they deserve.

# **Slack**

We are also available on Slack. Visit https://www.drupal.org/slack to see how you can join Drupal Slack. After that you can find us in the #opensocial channel. Our team will be available to answer your questions during our community hours there too.

# **Community hours**

Every week we are available on Slack on:

- Wednesday between 16:00 and 17:00 Europe/Amsterdam Timezone
- Friday between 10:00 and 11:00 Europe/Amsterdam Timezone

# Push a new release


## Multi-platform
As we have different requirements of platforms running (e.g. amd64 / arm64) for local and CI we need to build multi-platform images.
In order to build multi-platform images, we also need to create a builder instance as building multi-platform images is currently only supported when using BuildKit with docker-container and kubernetes drivers. Setting a single target platform is allowed on all buildx drivers.

```
docker buildx create --use
# building an image for two platforms
docker buildx build --platform=linux/amd64,linux/arm64 .
```

More info https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

## Pushing a new tag

Info: https://docs.docker.com/engine/reference/commandline/push/
CMD: `docker push [OPTIONS] NAME[:TAG]`

In order to push a new tag directly you need to navigate to the place where the dockerfile is located you wish to tag.
Afterwards you can run 

e.g. for drupal10 ci php 8.1

```
cd drupal10/ci-php8.1
docker buildx build --platform linux/amd64,linux/arm64 --push -t goalgorilla/open_social_docker:ci-drupal10-php8.1 .
```
