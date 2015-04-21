package im.tox.tox4j.av.exceptions;

import im.tox.tox4j.annotations.NotNull;
import im.tox.tox4j.exceptions.ToxException;

public final class ToxCallException extends ToxException {

  public enum Code {
    MALLOC,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CONNECTED,
    FRIEND_ALREADY_IN_CALL,
    INVALID_BIT_RATE,
  }

  @NotNull private final Code code;

  public ToxCallException(@NotNull Code code) {
    this.code = code;
  }

  @Override
  @NotNull
  public Code getCode() {
    return code;
  }

}
