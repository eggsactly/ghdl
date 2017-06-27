- https://travis-ci.org/1138-4EB
- https://hub.docker.com/r/ghdl/
- https://app.backhub.co/repositories

---

https://github.com/search?utf8=%E2%9C%93&q=author%3A1138-4EB

---

# Integrate build instructions into the GHDL documentation [#280](https://github.com/tgingold/ghdl/issues/280)

- Docker GCC
    - [GitHub:RafaelCatrou](https://github.com/RafaelCatrou/)
        - [docker_ghdl](https://github.com/RafaelCatrou/docker_ghdl)
        - [docker_gnat](https://github.com/RafaelCatrou/docker_gnat)
        - [docker_fpgatools](https://github.com/RafaelCatrou/docker_fpgatools)

# Nightly builds

- https://developer.github.com/v3/repos/releases/
- https://docs.travis-ci.com/user/environment-variables/
- https://docs.travis-ci.com/user/deployment/releases/
- https://github.com/travis-ci/travis-ci/issues/1476
- It'd be very useful to add some README/INSTALL and COPYING to each release. Some parts of the doc can be used to generate these on travis-ci deploy.

# Improve test suite log output handling

- [test.ps1](https://github.com/tgingold/ghdl/blob/master/dist/appveyor/test.ps1#L64-L78) for Appveyor can be taken as a reference.
- ¿Improve compilation output as well?

# Compile on Alpine Linux

```
GNA dir bug01:
analyze foo.vhdl
elaborate and simulate foo
/tmpRepo/deploy/lib/ghdl/libgrt.a(jumps.o): In function `get_bt_from_ucontext':
/tmpRepo/src/grt/config/jumps.c:100: undefined reference to `backtrace'
/tmpRepo/deploy/lib/ghdl/libgrt.a(jumps.o): In function `grt_save_backtrace':
/tmpRepo/src/grt/config/jumps.c:242: undefined reference to `backtrace'
collect2: error: ld returned 1 exit status
```

[Full log](https://travis-ci.org/1138-4EB/ghdl-tools/builds/199567697)

- [bugs.alpinelinux.org/issues/5079](https://bugs.alpinelinux.org/issues/5079)
- http://thread.gmane.org/gmane.linux.lib.musl.general/7356/focus=7369

- `libc` `zlib`
- You need to slightly patch `src/grt/jumps.c`, since it assumes that `backtrace()` is available on linux. Adding something like `&& defined (GLIBC)` or like `&& !defined (MUSL)` should fix the issue.
- If LLVM is used without the `libbacktrace`, `backtrace()` is useless.
libbacktrace is not needed for mcode
mcode need backtrace() but it doesn't use libbacktrace().

# Travis CI

- [Customizing the build](https://docs.travis-ci.com/user/customizing-the-build/)
- [Build/configuration file](http://blog.tgrrtt.com/exploring-the-travisci-configuration-file), `.travis.yml`:

```
  before_install:
  install:
  beforescript:
  script:
  after_success / after_failure:
  after_script:
  before_deploy:
  deploy:
  after_deploy:
```

## Deploy

- How to add the Windows files and the PDF automatically?
  - Maybe cross-compiling in a docker container, even if AppVeyor is used for testing?
  - The problem is that RTD is not very reliable. So the PDF might be missing or delayed while Travis is running. Change RTD to Travis? See dist/doc below.

secure: k1Idw3l/35mms1mESpO+5TmA2Kmf0UlMsxjgQiWikYu6va6icJjTzCHv6d3YjF6tzkouZZa74Gep22gg46uDWU6wtcBYq5X2IxEX1U3iRxi5CNXL77ZaYdj9Nn69cNImjGPqigJMJLOuIPi31ENlxgO83U07VYE1cV603+spvxw3a1TynrBIjdugiVMIFctrmt/zTIt/jBG1oQNLPdVTRFavnjpsFlnIcO5DvHvKxoDEpF3WwPcDr6h/bmnFZSfr8Sr2pptQU1S6qtHaLJPwg8w1f93nxr1LEK2MR8eVfS5XSEVC8nBZJHksdlwx/iiGyWEqEeXLXpoaHAO3aqkhjsMA1+mKbwtHjT7WBNWorKfmQP3ZTShhksPa+oBFitC33gXGCNCFMWSVdXrTIKIN8m//KSc3VTbxHL10afO9lCD955bZi1cpFZiE471BBXDxpN9Nv+1tV7RO7e6gm+94n9CYYkdCHcFK4hj0gGXDOQlUEEmZj4vAiwaDWfByfHxDNClT3rJ8tAm9BFjdDOI54NlA15/nyx+00Kw0FEZqvIemeMsCpz4Ril2bL8BZtwYm8e5sygqgdGODtRT5Q0hbHO2fuMpth4gvGGHraGlmH1Rez5BSnUsWVSQxV4Z+9/VZtQOK6HdfbbB8dd9SlOuEN1M9EqqEHBxdvHBkoMZy1uk=

secure: Pgst/qIHO6euzBssYnNTYCnd6IWHWJPolKESSvsxIDXG8V79BnCXClKMpAjBjlG/Zwx6Py6/3SWncE/dM7mFOXr/XBncAJkYBDcXat7W1c4znjm3bF4pB4R5LrFGi8jWg8mh+GdK9/zgiV+yvnM2N3cRPuZrJO4gwWs0mZUjHT42xbQOsJhC0AC2+REQtp+l/Gm3C7wZybCYfeUlnV1gLE69HtpET3w74aNVP7bAroN5u4TiA1dukLWMq+Ajw3Y24h0xXF9QlMLIb2sSSGGHuJtKiIZ81v61Sur1XsIxYU4WLT8WyOc2kQoaYIT8epQv1bOWBTPq+ID/P75I+T50q6aSSgU0E1aqz0IoJjMJgMEN1uqkNorNpCly1IlkpOk7DaohsaqodF0LG1OURmZatVq34ke6tsZSg0vq1VqGYqzrnSy6n2LuL85KmnFvUJlYunZ4vGCP0A2SHl5u/WFTwuX8fNmWuUeM07dr9y3Uztl1ixVLBTZwscgikCxJXSDdbFDEzxRAoKqSI2nc2UkYP2awmqhg44L3wtoBgzAg6hZUIqN9uRm3gO5d/mIo6nfmpJNKogIBun/ieTXcNMe4EnlxThotUirgmwb5N0BWHz5RRTwFQT15k7BgPoz/RMXOvAvaia3JFvF1sD8jZBL2fl4zWclwFKCf3ySTwRrXZG4=

# dist/doc as static binary (go/http)

- I'm guessing how to embbed the documentation in a single static executable, so that we can ship it to be used without internet connection.
- Installing Sphinx and LaTeX on Travis to replace RTD.
- If we use Travis-CI for that, it is no sense to keep RTD, since github pages would suffice.
  - We don't get the multi-version support on GitHub pages. We should implement it building multiple versions to diferent subdirs.
- They removed the gh-pages branch. New GH pages can only be stored in the master branch or in the docs folder of a master branch.

# Pending questions

- Dependency analysis
- Purge
	- GHDL repo is 45MB. Just expiring and purging it shrinks to 8MB. Would the history be lost? Or just that of the files which are no longer used? Can it be done so that no `reset --hard` is needed?
- https://mail.gna.org/public/ghdl-discuss/2016-04/msg00003.html
	
# Links
- https://paebbels.github.io/
- https://github.com/dwyl/learn-environment-variables
- http://www.dossmatik.de/ghdl/GHDL_uart_sim.pdf
