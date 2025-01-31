# pass-pwned
A [pass](https://www.passwordstore.org/) extension for checking against [Have I Been Pwned](https://haveibeenpwned.com/Passwords).

## Usage
```
Usage: pass pwned [--line,-l] [--all,-a] pass-name
   Check HIBP to see if the password has been exposed in a breach
   using SHA-1 and k-anonymity. Only the first five characters of
   the password's SHA1 hash ever get sent from your computer.
```

## Examples
```
# pass pwned truth/epsilonprogram.com
   Good news — no pwnage found!


# pass pwned social/lifeinvader.com
   Oh no - pwned!
   This password has been seen 6 times before.


# pass pwned -a
truth/epsilonprogram.com.gpg
	Good news — no pwnage found!

social/lifeinvader.com.gpg
   Oh no - pwned!
   This password has been seen 6 times before.

finance/lcn-exchange.com.gpg
	Good news — no pwnage found!

finance/thebankofliberty.com.gpg
	Good news — no pwnage found!


# pass pwned "finance/*"
finance/lcn-exchange.com.gpg
	Good news — no pwnage found!

finance/thebankofliberty.com.gpg
	Good news — no pwnage found!
```

## How does it work?
1. pass-pwned generates the [sha1sum](https://en.wikipedia.org/wiki/Sha1sum) of the password.
2. The sha1sum is then reduced to the first five characters.
3. This prefix character string is sent to the HIBP password api.
4. HIBP responds with a list of matching sha1sum suffixes.
5. pass-pwned checks to see if the suffix is in the list.

See [this blog post](https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/#cloudflareprivacyandkanonymity) for a more thorough description of the process, or [this blog post](https://blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/) for even more details.

## Installation
```
# sudo make install  
'./pwned.bash' -> '/usr/lib/password-store/extensions/pwned.bash'

# pass pwned --version
pass-pwned v0.1.0
```
