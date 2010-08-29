 *
 * This is really a "preview" of my forthcoming encryption library.  The
 * real deal will be much snazzier and cook your breakfast too.  Heck, it
 * might even have comments, too!  For now, if you'd like to get into the
 * encryption scene a bit, feel free to take this baby for a spin.  The
 * simple interface is documented below.  Dig into the code if you want
 * to try some more advanced things.
 *
 * Expect all of this to change significantly before the final release!
 *
 * Usage:
 *
 *   This library implements the RC5 encryption algorithm, originally
 *   developed by RSA, Inc.  It encrypts and decrypts data as text
 *   strings: if you data is not yet in text format, you'll have to
 *   provide your own method for translating it to and from text.
 *   In the specific case of encrypting savefiles, you'll probably
 *   want to look at savefile.ExportText() and savefile.ImportText().
 *
 *   RC5 encryption uses a key, or password, to secure data against
 *   attack.  To encrypt a plain text string p using key k and store
 *   it as cipher text c, simply call:
 *
 *		c = RC5_Encrypt(p, k)
 *
 *   Similarly, to decrypt a cipher text string c using key k into plain
 *   text p, call:
 *
 *		p = RC5_Decrypt(c, k)
 *
 *   By definition, RC5_Decrypt(RC5_Encrypt(p, k), k) == p.
 *
 **************************************************************************
 *
 * You can compile this library standalone to get a simple demo world.
 * Examine the demo code, play with the verbs, have fun.
 *
