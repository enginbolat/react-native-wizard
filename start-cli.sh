#!/bin/bash

# 🎨 Renkler
RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); CYAN=$(tput setaf 6); RESET=$(tput sgr0)

# 🐛 Debug
DEBUG=${DEBUG:-0}
run_cmd() {
  if [ "$DEBUG" -eq 1 ]; then echo "${CYAN}▶ $@${RESET}"; eval "$@"
  else eval "$@ > /dev/null 2>&1"; fi
}

# 🔎 Choose (gum/fzf/select)
choose() {
  QUESTION=$1; shift; OPTIONS=("$@")
  if command -v gum >/dev/null 2>&1; then
    gum choose --header "$QUESTION" "${OPTIONS[@]}"
  elif command -v fzf >/dev/null 2>&1; then
    printf "%s\n" "${OPTIONS[@]}" | fzf --header "$QUESTION"
  else
    echo "$QUESTION"
    select opt in "${OPTIONS[@]}"; do echo "$opt"; break; done
  fi
}

# 📦 PM kurulu mu?
ensure_pm_installed() {
  if [ "$1" = "yarn" ] && ! command -v yarn >/dev/null 2>&1; then
    echo "${YELLOW}📥 Yarn bulunamadı. Kuruluyor...${RESET}"
    npm install -g yarn > /dev/null 2>&1
  elif [ "$1" = "pnpm" ] && ! command -v pnpm >/dev/null 2>&1; then
    echo "${YELLOW}📥 pnpm bulunamadı. Kuruluyor...${RESET}"
    npm install -g pnpm > /dev/null 2>&1
  fi
}

# 🔍 PM tespit (lock dosyasından)
detect_pm_from_lock() {
  if [ -f "pnpm-lock.yaml" ]; then REAL_PM="pnpm"
  elif [ -f "yarn.lock" ]; then REAL_PM="yarn"
  else REAL_PM="npm"
  fi
}

# 📦 package env
ensure_package_env() {
  if [ ! -f "package.json" ]; then echo "${RED}❌ package.json yok. Init başarısız.${RESET}"; exit 1; fi
  if [ "$REAL_PM" = "yarn" ] && [ ! -f "yarn.lock" ]; then
    echo "${YELLOW}⚠️ yarn.lock yok, oluşturuluyor...${RESET}"; touch yarn.lock
  fi
  if [ "$REAL_PM" = "npm" ] && [ ! -f "package-lock.json" ]; then
    echo "${YELLOW}⚠️ package-lock.json yok, npm install sonrası oluşacak...${RESET}"
  fi
  if [ "$REAL_PM" = "pnpm" ] && [ ! -f "pnpm-lock.yaml" ]; then
    echo "${YELLOW}⚠️ pnpm-lock.yaml yok, oluşturuluyor...${RESET}"; touch pnpm-lock.yaml
  fi
}

# 📥 install
install_dependencies() {
  ensure_package_env
  echo "${CYAN}📥 Bağımlılıklar kuruluyor...${RESET}"
  if [ "$REAL_PM" = "yarn" ]; then run_cmd "yarn install"
  elif [ "$REAL_PM" = "pnpm" ]; then run_cmd "pnpm install"
  else run_cmd "npm install"; fi
}

# 📱 iOS simülatör seçimi
select_ios_simulator() {
  DEVICES=$(xcrun simctl list devices available | grep -E "iPhone" | sed -E 's/^[[:space:]]+//')
  IP16=$(echo "$DEVICES" | grep "iPhone 16")
  if [ -n "$IP16" ]; then DEVICE=$(echo "$IP16" | sort -Vr | head -n 1); echo "$DEVICE" | grep -oE "[0-9A-F-]{36}"; return; fi
  echo "${YELLOW}⚠️ iPhone 16 yok. Bir simülatör seçiniz:${RESET}"
  DEVICE_NAME=$(choose "📱 Simülatör seç:" $(echo "$DEVICES" | sed -E 's/ \([0-9A-F-]{36}\)//g'))
  echo "$DEVICES" | grep "$DEVICE_NAME" | grep -oE "[0-9A-F-]{36}" | head -n 1
}

echo "${CYAN}🚀 Proje Oluşturucu${RESET}"
echo "--------------------------------------------"

# 0) Expo mu CLI mı?
STACK=$(choose "Hangi akış?" "React Native Community CLI" "Expo")

# 1) Proje adı
read -p "📦 Proje adı: " PROJECT_NAME

if [ "$STACK" = "Expo" ]; then
  # —— Expo akışı
  EXPO_PM=$(choose "📦 Expo için package manager seç:" "npm" "yarn" "pnpm")
  ensure_pm_installed "$EXPO_PM"

  echo "${CYAN}📦 Expo projesi oluşturuluyor...${RESET}"
  if [ "$EXPO_PM" = "yarn" ]; then
    run_cmd "yarn create expo-app \"$PROJECT_NAME\" --yes"
  elif [ "$EXPO_PM" = "pnpm" ]; then
    run_cmd "pnpm create expo-app \"$PROJECT_NAME\" --yes"
  else
    run_cmd "npx create-expo-app \"$PROJECT_NAME\" --yes"
  fi

  if [ ! -d "$PROJECT_NAME" ]; then
    echo "${RED}❌ Proje klasörü bulunamadı. Expo init başarısız.${RESET}"
    exit 1
  fi

  cd "$PROJECT_NAME" || exit 1
  detect_pm_from_lock

  echo "${CYAN}--------------------------------------------${RESET}"
  POST=$(choose "⚡ Ekstra işlem ne yapılsın?" "Hiçbir şey yapma" "Expo iOS & Android çalıştır" "ESLint + Prettier kur")

  if [ "$POST" = "Expo iOS & Android çalıştır" ]; then
    echo "${CYAN}📱 Expo Metro başlatılıyor...${RESET}"
    run_cmd "npx expo start"
    echo "${CYAN}📱 (Expo) iOS çalıştırılıyor...${RESET}"
    run_cmd "npx expo run:ios"
    echo "${CYAN}🤖 (Expo) Android çalıştırılıyor...${RESET}"
    run_cmd "npx expo run:android"
    echo "${GREEN}✅ Expo iOS & Android çalıştırıldı. Script tamamlandı.${RESET}"
    exit 0

  elif [ "$POST" = "ESLint + Prettier kur" ]; then
    if [ "$REAL_PM" = "yarn" ]; then run_cmd "yarn add -D eslint prettier eslint-config-prettier eslint-plugin-prettier"
    elif [ "$REAL_PM" = "pnpm" ]; then run_cmd "pnpm add -D eslint prettier eslint-config-prettier eslint-plugin-prettier"
    else run_cmd "npm install --save-dev eslint prettier eslint-config-prettier eslint-plugin-prettier"; fi
    echo "${GREEN}✅ ESLint + Prettier yüklendi.${RESET}"
  fi

  echo "${GREEN}✅ Expo projesi hazır. İyi çalışmalar!${RESET}"
  exit 0
fi

# —— RN Community CLI akışı
# 2) Versiyon
read -p "📌 React Native versiyonu (örn: 0.76.5, boş bırak geç): " RN_VERSION
if [ -z "$RN_VERSION" ]; then
  RN_VERSION="0.81.0"
  echo "${GREEN}✅ Varsayılan versiyon: $RN_VERSION${RESET}"
elif [ "$RN_VERSION" = "0" ]; then
  echo "${RED}⚠️ Geçersiz versiyon girdiniz.${RESET}"
  echo "${YELLOW}✅ Mevcut stabil sürümler (0.70.0 – 0.81.0):${RESET}"
  VERSIONS=$(npm info react-native versions --json | \
    grep -oE "\"0\.(7[0-9]|8[0-1])\.[0-9]+\"" | \
    tr -d '"' | grep -v "rc" | grep -v "nightly" | sort -V)
  RN_VERSION=$(choose "⬇️ Versiyon seç:" $VERSIONS)
else
  VALID=$(npm info react-native@"$RN_VERSION" version 2>/dev/null)
  if [ -z "$VALID" ]; then
    echo "${RED}⚠️ $RN_VERSION geçersiz bir sürüm.${RESET}"
    echo "${YELLOW}✅ Mevcut stabil sürümler (0.70.0 – 0.81.0):${RESET}"
    VERSIONS=$(npm info react-native versions --json | \
      grep -oE "\"0\.(7[0-9]|8[0-1])\.[0-9]+\"" | \
      tr -d '"' | grep -v "rc" | grep -v "nightly" | sort -V)
    RN_VERSION=$(choose "⬇️ Versiyon seç:" $VERSIONS)
  else
    [[ ! $RN_VERSION =~ \.[0-9]+$ ]] && RN_VERSION="${RN_VERSION}.0"
  fi
fi

# 3) Package manager
REAL_PM=$(choose "📦 Package manager seç:" "npm" "yarn" "pnpm")
ensure_pm_installed "$REAL_PM"

# 4) Skip install
SKIP=$(choose "⏭️ Bağımlılıkları yüklemeyi atla?" "Hayır" "Evet")

# 5) Title
read -p "📝 App title (boş bırak geç): " TITLE; [ -z "$TITLE" ] && TITLE="$PROJECT_NAME"

# 6) Directory
read -p "📂 Directory (boş bırak varsayılan): " DIR

# Init’te kullanılacak PM: pnpm seçilse bile init **npm** ile
PM_FOR_INIT="$REAL_PM"; [ "$REAL_PM" = "pnpm" ] && PM_FOR_INIT="npm"

# 🔨 Init komutu
CMD="npx @react-native-community/cli init \"$PROJECT_NAME\" --version \"$RN_VERSION\" --pm $PM_FOR_INIT --title \"$TITLE\" --skip-install"
[ -n "$DIR" ] && CMD="$CMD --directory \"$DIR\""

echo "${CYAN}📦 Proje oluşturuluyor...${RESET}"
run_cmd "$CMD"

# Klasör kontrol
if [ ! -d "$PROJECT_NAME" ]; then
  echo "${RED}❌ Proje klasörü bulunamadı. CLI init başarısız.${RESET}"
  exit 1
fi
cd "$PROJECT_NAME" || exit 1

# pnpm ise lock hazırla ve daima install yap
if [ "$REAL_PM" = "pnpm" ] && [ ! -f "pnpm-lock.yaml" ]; then touch pnpm-lock.yaml; fi
if [ "$REAL_PM" = "pnpm" ]; then install_dependencies
elif [ "$SKIP" != "Evet" ]; then install_dependencies
fi

# iOS pod install
if [ -d "ios" ] && command -v pod >/dev/null 2>&1; then
  echo "${CYAN}📥 Pod dosyaları kuruluyor...${RESET}"
  if [ "$DEBUG" -eq 1 ]; then run_cmd "cd ios && pod install && cd .."
  else (cd ios && pod install > /dev/null 2>&1 && cd ..); fi
fi

echo "${CYAN}--------------------------------------------${RESET}"
POST=$(choose "⚡ Ekstra işlem ne yapılsın?" "Hiçbir şey yapma" "iOS & Android build dene" "ESLint + Prettier kur")

if [ "$POST" = "iOS & Android build dene" ]; then
  install_dependencies

  if ! grep -q "\"ios\":" package.json; then
    TMP=$(mktemp)
    jq '.scripts.ios="react-native run-ios" | .scripts.android="react-native run-android"' package.json > "$TMP" && mv "$TMP" package.json
  fi

  # iOS (CLI, xcodebuild → simctl install → simctl launch)
  if command -v xcrun >/dev/null 2>&1; then
    SIMULATOR_UDID=$(select_ios_simulator)
    if [ -n "$SIMULATOR_UDID" ]; then
      echo "${CYAN}📱 iOS uygulaması derleniyor...${RESET}"
      xcodebuild -workspace "ios/$PROJECT_NAME.xcworkspace" \
        -scheme "$PROJECT_NAME" \
        -configuration Debug \
        -sdk iphonesimulator \
        -destination "id=$SIMULATOR_UDID" \
        -derivedDataPath build > /dev/null 2>&1

      echo "${CYAN}📥 App install ediliyor...${RESET}"
      xcrun simctl install "$SIMULATOR_UDID" "build/Build/Products/Debug-iphonesimulator/$PROJECT_NAME.app"

      echo "${CYAN}🚀 App launch ediliyor...${RESET}"
      xcrun simctl launch "$SIMULATOR_UDID" "org.reactjs.native.example.$PROJECT_NAME" > /dev/null 2>&1
    fi
  fi

  # Android (CLI)
  echo "${CYAN}🤖 Android uygulaması başlatılıyor...${RESET}"
  if [ "$REAL_PM" = "yarn" ]; then run_cmd "yarn android"
  elif [ "$REAL_PM" = "pnpm" ]; then run_cmd "pnpm android"
  else run_cmd "npm run android"; fi

  echo "${GREEN}✅ iOS & Android build başlatıldı. Script tamamlandı.${RESET}"
  exit 0

elif [ "$POST" = "ESLint + Prettier kur" ]; then
  install_dependencies
  if [ "$REAL_PM" = "yarn" ]; then run_cmd "yarn add -D eslint prettier eslint-config-prettier eslint-plugin-prettier"
  elif [ "$REAL_PM" = "pnpm" ]; then run_cmd "pnpm add -D eslint prettier eslint-config-prettier eslint-plugin-prettier"
  else run_cmd "npm install --save-dev eslint prettier eslint-config-prettier eslint-plugin-prettier"; fi
  echo "${GREEN}✅ ESLint + Prettier yüklendi.${RESET}"
fi
