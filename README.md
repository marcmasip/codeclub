# 🐧 Linux Code Club Guides

** NOTE: This is an incomplete experiment please do not expect results **


Welcome to **Linux Code Club**, an experimental (*and slightly chaotic*) solution for building your very own Linux system — based on the legendary LFS/BLFS guides, but with less scrolling and more scripting.

We’re talking about Bash-powered wizardry, smart macros, compressed procedures, enough DIY spirit to build an operating system from the void, and why not some vive coding.

Think of it as **LFS with cheat codes**.  
Think of it as your personal Linux dojo.  
Think of it as... *The Club*™.



# 🚀 Getting Started

Scripts are organized using this magic incantation:

```
GUIDE=<platform> CHAPTER=<category> ITEM=<thing to build>
```

There are two main entry points into the madness:

- **util/guide-64pre.sh** → Bootstraps a new system (the sorcerer’s apprentice).  
- **util/guide-64.sh** → Adds software to your creation (the blacksmith).

Other helpful sidekicks:

- **util/guide-NAME-CHAPTER.sh** → Spells to build/install individual things.
- **util/obtain.txt** → The sacred scroll of source URLs.
- **util/obtain_desc.txt** → Descriptions, rumors, and whispers about those sources.



## 🧪 x86_64 Multilib Sequence (a.k.a. “Let’s Make a Linux”)

1. **Create a 5GB disk image** in `64/dist/sysroot.img` (ext4) and mount it like a champion:

```bash
./guide-64pre.sh tools create-disk
./guide-64pre.sh tools mount-disk
./guide-64pre.sh tools create-files
```

Say hello to `$ODIR`, where the magic happens.

2. **Summon a toolchain and a minimal system**:

```bash
./guide-64pre.sh tools all
```

3. (Optional) **Enter the realm** with `chroot`:

```bash
./guide-64pre.sh join
```

4. **Finalize your baby Linux**:

```bash
./guide-64pre.sh tools2 all
./guide-64pre.sh tools2 clean
```

5. **Build base components** (don’t forget to join first!):

```bash
./guide-64.sh base all
```

6. **Build additional components** (e.g., "windows"):

```bash
./guide-64.sh windows all
```

7. **Release the disk back into the wild**:

```bash
./guide-64pre.sh tools umount-disk
```

8. **Prepare a real disk partition** (like `/dev/sdb1`) with at least 5GB to continue.



# 📚 The Lore Behind the Scripts
So here’s the deal: this whole thing is a kind of Bash poetry experiment that compresses the mighty LFS/BLFS into something... bearable.
Instead of writing hundreds of lines manually, we juggle with macros like pros.
Each chapter is a case over an $ITEM, and the source library lives in $LDIR. By default, the source is just named after the item (SRC=$ITEM).
When building:
- A fresh copy of the source is unpacked into $SDIR,
- The build takes place in $BDIR (both usually in RAM, to avoid stressing your precious disk),
- And finally, the compiled result is installed into $ODIR, your actual system tree.



## 🧙 The Holy Build Trinity
Each build usually involves the following sacred rites:
- `O`: **Obtain** the source  
- `CF`: **Configure** it  
- `MO`: **Make** it  
- `MI`: **Make install**, baby

And often, the only thing that matters is configuring it right — so we just say:

```bash
OA  # "Obtain All" = O + CF + MO + MI
```

Boom. Done. Macros are love. Macros are life.

Want to add an item? Easy:

```bash
"item") OA --with-feature ;;
```

Even shorter with a reusable default:

```bash
r="OA --prefix=/usr"

case "$ITEM" in
  "item") $r --disable-static ;;
  *) $r ;;
esac
```



## 📦 What “Obtain” (`O`) Actually Does

- Looks for your `$SRC` in `$LDIR`, either as a tarball or under `develop/`
- If it doesn’t exist, it grabs it from the Internets™
- Copies it fresh to `$SDIR`
- Drops you into the build dir 

By default, the build happens in $SDIR/$SRC. But you can override that using WBD — a "With Build Dir" macro — to build in a custom $BDIR/$SRC.
```
OA            # uses $SDIR/$SRC → BD → CF → MO → MI
WBD && OA     # switches to $BDIR/$SRC instead
```

## 🔁 About Entry Scripts

These things set up your environment, load the chapter/item definitions, and run "all" sequences.

It logs each item's result to `var/club/log/<item>.res` and makes sure it doesn’t build the same thing twice (ain’t nobody got time for that):

```bash
if [ "$2" == "all" ]; then
  R item1
  R item2
  DO_R
fi
```

When the item’s done, we clean up the evidence from `$SDIR` and `$BDIR`. Poof. Like it never happened.


**And that’s basically it.  
Welcome to the Club. 😎**
