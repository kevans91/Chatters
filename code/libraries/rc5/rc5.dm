/*
 * RC5 Encryption Library version 0 (Not Ready For Release Just Yet)
 *
 **************************************************************************
 *
 * Copyright 2002 Mike Heasley (a.k.a. Air Mapster)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 **************************************************************************
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
 */

// This stuff will go in its own library sooner or later...
proc/num2hex(d as num, digits=0)
	var/result = ""
	d = abs(d)
	do
		var/rem = d % 16
		switch (rem)
			if (10)
				result = "A[result]"
			if (11)
				result = "B[result]"
			if (12)
				result = "C[result]"
			if (13)
				result = "D[result]"
			if (14)
				result = "E[result]"
			if (15)
				result = "F[result]"
			else
				var/c = num2text(rem)
				result = "[c][result]"
		d = round(d / 16)
	while (d)
	if (digits && isnum(digits))
		var/len = lentext(result)
		for (var/i = digits; i > len; i--)
			result = "0[result]"
	return result

proc/hex2num(h)
	if (findtext(h, "0x", 1, 3))
		h = copytext(h, 3)
	var/l = lentext(h)
	var/sixteen = 1
	var/result = 0
	var/digit = 0
	while (l)
		var/c = copytext(h, l)
		h = copytext(h, 1, l)
		l = lentext(h)
		switch (c)
			if ("A", "a") digit = 10
			if ("B", "b") digit = 11
			if ("C", "c") digit = 12
			if ("D", "d") digit = 13
			if ("E", "e") digit = 14
			if ("F", "f") digit = 15
			if ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
				digit = text2num(c)
			else
				return
		result += digit * sixteen
		sixteen *= 16
	return result

proc/test2list_rc5(t)
	var/list/txtlist = new
	var/added = 0
	while (lentext(t) % 4)
		t += " "
		added += 1
	if (istext(t))
		var/l = lentext(t) / 2
		for (var/i = 0; i < l; i++)
			var/off1 = (2 * i) + 1
			var/off2 = off1 + 1
			txtlist += (text2ascii(copytext(t, off1, off2)) << 8) | text2ascii(copytext(t, off2, off2+1))
	if (added)
		txtlist += added
	return txtlist

proc/list2text_rc5(list/l)
	var/txt = ""
	var/added = 0
	if (l.len % 2)
		added = l[l.len]
		l.len = l.len - 1
	for (var/i = l.len - 1; i > 0; i -= 2)
		var/result = ascii2text((l[i] >> 8) & 255) + ascii2text(l[i] & 255) + ascii2text((l[i+1] >> 8) & 255) + ascii2text(l[i+1] & 255)
		txt = "[result][txt]"
	if (added)
		txt = copytext(txt, 1, lentext(txt) + 1 - added)
	return txt

proc/list2hex(list/l)
	var/hex = ""
	for (var/n in l)
		hex += num2hex(n, 4)
	return hex

proc/hex2list(hex)
	var/list/l[0]
	var/len = round(lentext(hex) / 4)
	for (var/i = 0; i < len; i++)
		var/off = i*4
		var/hnum = copytext(hex, off+1, off+5)
		l += hex2num(hnum)
	return l

// Generic crypto object: holds the cipher/plain text, type of encryption,
// type of input/output, etc.
//
// Currently supported input/output types:
// 		list: used internally; every two characters represented by a number in the list
//		hex:  hexadecimal number as string
//		text: raw ascii text; note that values of 0 will prematurely terminate the string
// Future will include base64, BigNum, more...
//
crypto
	var
		data[0]

	New(t, type="text")
		src.SetData(t, type)

	proc/SetData(t, type="text")
		switch (type)
			if ("list")
				if (istype(t, /list))
					var/list/lt = t
					src.data = lt.Copy()
			if ("hex")
				if (istext(t))
					src.data = hex2list(t)
			else
				if (istext(t))
					src.data = test2list_rc5(t)

	proc/Encrypt(key, t=null, type="text")
		if (t)
			src.SetData(t, type)
		if (src.data.len)
			src.DoEncrypt(key)

	proc/Decrypt(key, t=null, type="hex")
		if (t)
			src.SetData(t, type)
		if (src.data.len)
			src.DoDecrypt(key)

	proc/DoEncrypt(key)

	proc/DoDecrypt(key)

	proc/PrintHex()
		if (src.data.len)
			return list2hex(src.data)

	proc/PrintList()
		if (src.data.len)
			return src.data

	proc/PrintText()
		if (src.data.len)
			return list2text_rc5(src.data)

// Begin RC5 implementation
crypto/rc5
	var
		const/w = 16
		r = 16
		b = 16
		c = 8
		t = 34
		S[0]
		const/P = 47073
		const/Q = 40503
		lasta = 0
		lastb = 0
		uselast = FALSE

	proc/rotl(x, y)
		return x << (y & (src.w - 1)) | (x >> (src.w - (y & (src.w - 1))))

	proc/rotr(x, y)
		return x >> (y & (src.w - 1)) | (x << (src.w - (y & (src.w - 1))))

	proc/Init(key)
		var/lt = lentext(key)
		if (!lt)
			return 0

		if (lt % 2)
			key += " "
			lt++

		src.b = lt
		src.c = round(src.b / 2) + 1

		var/i = 0
		var/u = src.w / 8
		var/L[src.c]
		L[src.c] = 0
		for (i = src.b - 1; i != -1; i--)
			var/idx = round(i / u) + 1
			L[idx] = (L[idx] << 8) + text2ascii(copytext(key, i+1, i+2))

		src.S.len = src.t
		src.S[1] = src.P
		for (i = 1; i < src.t; i++)
			src.S[i+1] = src.S[i] + Q

		var/A = 0
		var/B = 0
		var/t3 = 3 * src.t
		var/j = 0
		i = 0
		for (var/k = 0; k < t3; k++)
			src.S[i+1] = src.rotl(src.S[i+1]+A+B, 3)
			A = src.S[i+1]
			L[j+1] = src.rotl(L[j+1]+A+B, A+B)
			B = L[j+1]
			i = (i+1) % src.t
			j = (j+1) % src.c
		return 1

	DoEncrypt(key)
		if (!src.Init(key))
			return ""
		var/list/lst = src.data
		for (var/i = 1; i < lst.len; i += 2)
			var/a = lst[i]
			var/b = lst[i+1]
			a = (a + src.S[1]) % 65536
			b = (b + src.S[2]) % 65536
			for (var/j = 1; j <= src.r; j++)
				a = (src.rotl(a^b, b) + S[(2*j)+1]) % 65536
				b = (src.rotl(b^a, a) + S[(2*j)+2]) % 65536
			if (i > 1)
				a ^= lst[i-2]
				b ^= lst[i-1]
			lst[i] = a
			lst[i+1] = b

	DoDecrypt(key)
		if (!src.Init(key))
			return ""
		var/offset = 1
		var/list/cipher = src.data
		if (cipher.len % 2)
			offset = 2
		for (var/i = cipher.len - offset; i > 0; i -= 2)
			var/a = cipher[i]
			var/b = cipher[i+1]
			if (i > 1)
				a ^= cipher[i-2]
				b ^= cipher[i-1]
			for (var/j = src.r; j > 0; j--)
				b = src.rotr(b - src.S[(2*j)+2], a) ^ a
				a = src.rotr(a - src.S[(2*j)+1], b) ^ b
			a -= src.S[1]
			b -= src.S[2]
			if (a < 0) a = 65536 + a
			if (b < 0) b = 65536 + b
			cipher[i] = a
			cipher[i+1] = b

proc/RC5_Encrypt(t, k)
	var/crypto/rc5/r = new(t)
	r.Encrypt(k)
	return r.PrintHex()

proc/RC5_Decrypt(t, k)
	var/crypto/rc5/r = new(t, type="hex")
	r.Decrypt(k)
	return r.PrintText()

