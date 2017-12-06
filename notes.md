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

## Deploy

- How to add the Windows files and the PDF automatically?
  - Maybe cross-compiling in a docker container, even if AppVeyor is used for testing?
  - The problem is that RTD is not very reliable. So the PDF might be missing or delayed while Travis is running. Change RTD to Travis? See dist/doc below.

# dist/doc as static binary (go/http)

- I'm guessing how to embbed the documentation in a single static executable, so that we can ship it to be used without internet connection.
- Installing Sphinx and LaTeX on Travis to replace RTD.
- If we use Travis-CI for that, it is no sense to keep RTD, since github pages would suffice.
  - We don't get the multi-version support on GitHub pages. We should implement it building multiple versions to diferent subdirs.

# Pending questions

- Dependency analysis
	
# Links
- http://www.dossmatik.de/ghdl/GHDL_uart_sim.pdf

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
