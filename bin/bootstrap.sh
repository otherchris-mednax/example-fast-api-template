#!/usr/bin/env bash

# bin/bootstrap.sh: Resolve all dependencies that the project requires to run.

set -e

# Set the working directory to be the project's base directory; all
# subsequent paths are relative to that base directory.
cd "$(dirname "$0")/.."

source bin/build_variables.sh

quiet_apt_get()
{
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq "$@"
}

is_wsl()
{
	case "$(uname -r)" in
	*microsoft* ) true ;; # WSL 2
	*Microsoft* ) true ;; # WSL 1
	* ) false;;
	esac
}

installed()
{
  return "$(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')"
}

echo -e "${BLUE}───────────────────────────────────────────────────────────────────────${RESET}"
if [ -z "${CI}" ]; then
    echo " RUNNING LOCALLY…"
else
    echo " RUNNING IN CI…"
    if [ "${CIRCLE_BRANCH}" != "main" ]; then
        echo " NOT ON MAIN BRANCH…"
    fi
fi
echo -e " VERSION: $VERSION"
echo -e "${BLUE}───────────────────────────────────────────────────────────────────────${RESET}"

# Install system dependencies
# macOS
if command -v brew >/dev/null 2>&1 && [ -f "Brewfile" ]; then
  brew bundle check >/dev/null 2>&1 || {
    echo "🤖 ⟶  Installing system prerequisites…"
    brew bundle --quiet
    az login --output none --only-show-errors
    az acr login --name mednax
  }
fi
# Ubuntu/Debian/Mint
if command -v apt-get >/dev/null 2>&1; then
  echo "🤖 ⟶  Installing system prerequisites…"
  # pyenv dependencies, see:
  # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  pkgs=(make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev)
  missing_pkgs=()

  for pkg in "${pkgs[@]}"; do
    if ! eval installed "$pkg"; then
      missing_pkgs+=("$pkg")
    fi
  done

  if [ -n "${missing_pkgs[*]}" ]; then
    sudo apt-get update -qq
    quiet_apt_get "${missing_pkgs[@]}" < /dev/null > /dev/null
  fi

  if ! command -v docker >/dev/null 2>&1; then
    if is_wsl; then
      echo "${RED}🤖 ⟶  Unable to install Docker in WSL.${RESET}"
      echo ""
      echo "You'll need to install Docker Desktop for Windows manually:"
      echo ""
      echo "https://docs.docker.com/desktop/windows/install/"
      echo ""
      echo "When installing, make sure WSL 2 is selected as the backend."
      echo "After installing, enable WSL integration:"
      echo ""
      echo "https://docs.docker.com/desktop/windows/wsl/#enabling-docker-support-in-wsl-2-distros"
      echo ""
      exit 1
    else
      echo "🤖 ⟶  Installing Docker…"
      curl -fsSL https://get.docker.com | sudo sh
      getent group docker >/dev/null 2>&1 \
        || sudo groupadd docker \
        && sudo usermod -aG docker "$USER" \
        && newgrp docker
    fi
  fi

  if ! command -v az >/dev/null 2>&1; then
    echo "🤖 ⟶  Installing Azure CLI…"
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    az login --output none --only-show-errors
    az acr login --name mednax
  fi
fi

if ! command -v pyenv >/dev/null 2>&1; then
  echo "🤖 ⟶  Installing pyenv…"
  curl https://pyenv.run | bash
  # This will setup pyenv for the duration of the script, but the user still
  # needs to make the setup permanent in their shell configuration file.
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  pyenv_installed=true
fi

# If Poetry adds support for reading versions from pyproject.toml, we can
# talk about removing the .python-version file. See this issue for more
# details: https://github.com/pyenv/pyenv/issues/1233.
if [ -f ".python-version" ] && [ -z "$(pyenv version-name 2>/dev/null)" ]; then
  echo "🤖 ⟶  Installing Python…"
  pyenv install --skip-existing
fi

if ! command -v poetry >/dev/null 2>&1; then
  echo "🤖 ⟶  Installing Poetry…"
  curl -sSL https://install.python-poetry.org | python3 -
  # This will setup Poetry for the duration of the script, but the user still
  # needs to make the setup permanent in their shell configuration file.
  export PATH="$HOME/.local/bin:$PATH"
  poetry_installed=true
fi

if [ -z "$JFROG_USER" ] || [ -z "$ARTIFACT_ACCESS_TOKEN" ]; then
  echo "${RED}🤖 ⟶  You need to configure yout environment variables.${RESET}"
  echo ""
  echo "Add to (and re-source) your shell configuration file (~/.bashrc):"
  echo ""
  echo "${PURPLE}export JFROG_USER=<your_name_here@pediatrix.com>${RESET}"
  echo "${PURPLE}export ARTIFACT_ACCESS_TOKEN=<your_artifactory_api_key>${RESET}"
  echo ""
  echo "Once these are added, run \`make bootstrap\`."
  echo ""
  exit 1
fi

if [ -z "$POETRY_HTTP_BASIC_PEDIATRIX_USERNAME" ] || [ -z "$POETRY_HTTP_BASIC_PEDIATRIX_PASSWORD" ]; then
  echo "🤖 ⟶  Configuring Artifactory login…"
  [ -n "$POETRY_HTTP_BASIC_PEDIATRIX_USERNAME" ] || export POETRY_HTTP_BASIC_PEDIATRIX_USERNAME="$JFROG_USER"
  [ -n "$POETRY_HTTP_BASIC_PEDIATRIX_PASSWORD" ] || export POETRY_HTTP_BASIC_PEDIATRIX_PASSWORD="$ARTIFACT_ACCESS_TOKEN"
  echo "${BLUE}🤖 ⟶  Configure Poetry's repository authentication.${RESET}"
  echo ""
  echo "To make this message go away, add these to (and re-source) your shell configuration file (~/.bashrc):"
  echo ""
  echo "${PURPLE}export POETRY_HTTP_BASIC_PEDIATRIX_USERNAME=\"\$JFROG_USER\"${RESET}"
  echo "${PURPLE}export POETRY_HTTP_BASIC_PEDIATRIX_PASSWORD=\"\$ARTIFACT_ACCESS_TOKEN\"${RESET}"
  echo ""
fi

if [ -f "pyproject.toml" ]; then
  echo "🤖 ⟶  Installing Python dependencies…"
  if [[ $(uname -m) == 'arm64' ]]; then
    export CRYPTOGRAPHY_DONT_BUILD_RUST=1
  fi
  poetry install
fi

if [ -n "$pyenv_installed" ]; then
  echo "${BLUE}🤖 ⟶  Don't forget to finish setting up pyenv.${RESET}"
  echo ""
  echo "Add to (and re-source) your shell configuration file (~/.bashrc):"
  echo ""
  echo "${PURPLE}export PYENV_ROOT=\"\$HOME/.pyenv\"${RESET}"
  echo "${PURPLE}command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\"${RESET}"
  echo "${PURPLE}eval \"\$(pyenv init -)\"${RESET}"
  echo ""
fi

if [ -n "$poetry_installed" ]; then
  echo "${BLUE}🤖 ⟶  Don't forget to finish setting up Poetry.${RESET}"
  echo ""
  echo "Add to (and re-source) your shell configuration file (~/.bashrc):"
  echo ""
  echo "${PURPLE}command -v poetry >/dev/null || export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
  echo ""
fi
