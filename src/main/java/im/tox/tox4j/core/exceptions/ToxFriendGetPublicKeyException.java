package im.tox.tox4j.core.exceptions;

import im.tox.tox4j.annotations.NotNull;
import im.tox.tox4j.exceptions.ToxException;

public final class ToxFriendGetPublicKeyException extends ToxException {

  public enum Code {
    FRIEND_NOT_FOUND,
  }

  @NotNull private final Code code;

  public ToxFriendGetPublicKeyException(@NotNull Code code) {
    this.code = code;
  }

  @Override
  @NotNull
  public Code getCode() {
    return code;
  }

}
