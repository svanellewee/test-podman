FROM debian:stable

ARG USERNAME=scatman
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -m --uid $USER_UID --gid $USER_GID  $USERNAME
    
RUN apt-get update 

USER $USERNAME
WORKDIR /home/$USERNAME

COPY --chown=$USER_UID:$USER_GID some_subdir/ some_subdir/
