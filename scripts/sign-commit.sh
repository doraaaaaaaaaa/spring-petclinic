#!/bin/bash

# Ajoute "edited by benarbidorra" au message de commit
COMMIT_MSG_FILE=$1
echo "" >> $COMMIT_MSG_FILE
echo "edited by benarbidorra" >> $COMMIT_MSG_FILE
