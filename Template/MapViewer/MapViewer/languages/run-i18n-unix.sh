#!/bin/bash

APP_NAME=MapViewer
LANGUAGES_FOLDER=${APP_NAME}/languages

#----------------------------------------------------------------------

set_workdir() {
  WORKDIR="$(cd "$(dirname "$0")/../.."; pwd)"
  echo $WORKDIR
}

#----------------------------------------------------------------------

set_lreleasedir_appstudio() {
  case $(uname -s) in
  Darwin)
    APPSTUDIODIR=~/Applications/ArcGIS/AppStudio
    if [ -f "${APPSTUDIODIR}/tools/lrelease" ]; then
      LRELEASEDIR=${APPSTUDIODIR}/bin
      export PATH=${LRELEASEDIR}:${PATH}
      LRELEASE=lrelease
      LUPDATE=lupdate
      return
    fi
    ;;
  Linux)
    APPSTUDIODIR=~/Applications/ArcGIS/AppStudio
    if [ -f "${APPSTUDIODIR}/bin/lrelease" ]; then
      LRELEASEDIR=${APPSTUDIODIR}/bin
      export PATH=${LRELEASEDIR}:${PATH}
      LRELEASE=lrelease
      LUPDATE=lupdate
      return
    fi
    ;;
  MINGW*)
    APPSTUDIODIR=~/Applications/ArcGIS/AppStudio
    if [ -f "${APPSTUDIODIR}/bin/lrelease.exe" ]; then
      LRELEASEDIR=${APPSTUDIODIR}/bin
      export PATH=${LRELEASEDIR}:${PATH}
      LRELEASE=lrelease.exe
      LUPDATE=lupdate.exe
      return
    fi
    ;;
  esac
}

#----------------------------------------------------------------------

set_lreleasedir_qt() {
  set_lreleasedir_appstudio
  if [ "${LRELEASEDIR}" != "" ]; then return; fi
  APPSTUDIODIR=

  case $(uname -s) in
  Darwin)
    qtdirs=(~/Qt*/*/clang_64)
    ;;
  Linux)
    qtdirs=(~/Qt*/*/gcc_64)
    ;;
  MINGW*)
    qtdirs=(/c/Qt*/*/*/mingw*_64)
    ;;
  *)
    echo "System $(uname -s) not supported"
    for test_dir in ~/Qt*/*/*/; do
      if [ -f "$test_dir/bin/lrelease" ]; then
        echo Possible candidate $test_dir
      fi
    done
    exit 1
    ;;
  esac

  for test_dir in "${qtdirs[@]}"
  do
    if [ -f "$test_dir/bin/lrelease" ]; then
      export QTDIR=$test_dir
      export PATH=$QTDIR/bin:$PATH
    fi
  done

  if [ "$QTDIR" == "" ]; then
    echo QTDIR not detected.
    exit 1
  fi
}

set_lreleasedir() {
  set_lreleasedir_appstudio
  if [ "${LRELEASEDIR}" != "" ]; then return; fi
  set_lreleasedir_qt
  if [ "${LRELEASEDIR}" != "" ]; then return; fi
}

#----------------------------------------------------------------------

main() {
  errors=0
  exit_status=0
  set_workdir
  set_lreleasedir
  ( set -x; lupdate "$WORKDIR" -extensions qml -ts "$WORKDIR/${APP_NAME}/languages/${APP_NAME}.ts" )
  ( set -x; lupdate "$WORKDIR" -extensions qml -pluralonly -ts "$WORKDIR/${APP_NAME}/languages/${APP_NAME}_en.ts" )
  for f in $WORKDIR/${LANGUAGES_FOLDER}/*.ts ; do
    if [ "$f" == "$WORKDIR/${LANGUAGES_FOLDER}/${APP_NAME}.ts" ]; then
      continue
    fi
    lrelease $f
    status=$?
    if [ $status != 0 ]; then
      exit_status=$status
      errors=$((errors+1))
    fi
  done

  if [ "$exit_status" != "0" ]; then
    >&2 echo "Exiting with "$errors" errors"
    exit $exit_status
  fi
}

main
