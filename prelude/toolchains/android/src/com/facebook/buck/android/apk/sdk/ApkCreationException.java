/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under both the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree and the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree.
 */

package com.facebook.buck.android.apk.sdk;

/** An exception thrown during packaging of an APK file. */
public final class ApkCreationException extends Exception {
  private static final long serialVersionUID = 1L;

  public ApkCreationException(String format, Object... args) {
    super(String.format(format, args));
  }

  public ApkCreationException(Throwable cause, String format, Object... args) {
    super(String.format(format, args), cause);
  }

  public ApkCreationException(Throwable cause) {
    super(cause);
  }
}
