#!/bin/bash

aa="12345"

fn() {
  local -n bb=$1
  bb=3456
}

echo "aa: ${aa}"
fn "aa"
echo "aa: ${aa}"
