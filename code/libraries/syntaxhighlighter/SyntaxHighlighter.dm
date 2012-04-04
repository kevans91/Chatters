/*
	SyntaxHighlighter Library
	version 1.1 by Lummox JR

	A simple syntax highlighter designed for browse() output


	There are only three procs you need to know:

		TrimLeadingTabs(code)
			Provide the original, unprocessed code, and this proc will return a copy
			with any extra leading tabs stripped away. This is nice for when people
			are too lazy to remove the extra tabs before posting.

		HighlightCode(code, tabsize=4, showtabs, embed)
			Input the code to be displayed, and this will return a version with full
			HTML highlighting. Tabs are converted to spaces, and are size 4 by default
			just like in ALL CIVILIZED EDITORS. If you set showtabs to a true value,
			then tabs will display with a » symbol just like if you hit Ctrl+T in
			Dream Maker. If you set embed to a true value, then syntax highlighting
			will be done in embedded expressions within strings, instead of leaving
			them the default color.

		DefaultHighlightStyles(style1,css1,style2,css2,...)
			Returns a <style> tag with the default highlight colors already included.
			If you provide any arguments to this proc, you can override the defaults.
			The default styles are:

			pre.code {background:#fff; margin:0.5em}
			.comment {color:#666}
			.preproc {color:#008000}
			.number {color:#800000}
			.ident {color:#606}
			.keyword {color:#00f}
			.string {color:#0096b4}

			If you wanted to highlight identifiers in gold, you could call this as:

			DefaultHighlightStyles(".ident","color:#808000")
 */

var/list/DMKeywordList=list(\
	"break", "new", "del", "for", "global", "var", "proc", "verb", "set",
	"static", "arg", "const", "goto", "if", "in", "as", "continue",
	"return", "do", "while", "else", "switch", "tmp", "to")

var/list/_DefaultHighlightStyles=list(\
	"pre.code"="background:#fff; margin:0.5em",
	".comment"="color:#666",
	".preproc"="color:#008000",
	".number"="color:#800000",
	".ident"="color:#606",
	".keyword"="color:#00f",
	".string"="color:#0096b4")

proc/IsDMNumber(txt)
	var/i,L=length(txt)
	var/ch=text2ascii(txt)
	if(ch==48 && length(txt)>2 && text2ascii(txt,2)==120)
		for(i=3,i<=L,++i)
			ch=text2ascii(txt,i)
			if(ch==92 && i+1<=L && text2ascii(txt,i+1)==10)
				++i; continue
			if(ch<48) return
			if(ch>57 && ch<65) return
			if(ch>70 && ch<97) return
			if(ch>102) return
		return 1
	var/d,e
	for(i=1,i<=L,++i)
		ch=text2ascii(txt,i)
		if(ch>=48 && ch<=57) continue
		if(ch==92 && i+1<=L && text2ascii(txt,i+1)==10)
			++i; continue
		if(ch==46)
			if(d || ++i>L) return
			ch=text2ascii(txt,i)
			if(ch<48 || ch>57) return
			d=1
			continue
		if(ch==101 || ch==69)
			if(e || ++i>L) return
			ch=text2ascii(txt,i)
			if(ch!=45 && ch!=43) --i
			e=1; d=1
			continue
		return
	return 1

#define INSERT_SYN_BLOCK(i,blk) \
	code=copytext(code,1,i)+(blk)+copytext(code,i); I+=length(blk); nLength+=length(blk)
#define REPLACE_SYN_BLOCK(i,blk) \
	code=copytext(code,1,i)+(blk)+copytext(code,(i)+1); I+=length(blk)-1; nLength+=length(blk)-1

#define COOKIE_COMMENT			1
#define COOKIE_EXT_COMMENT		2
#define COOKIE_BRACE			4
#define COOKIE_STRING			8
#define COOKIE_EXT_STRING		16
#define COOKIE_CHAR				32
#define COOKIE_PREPROCESSOR		64
#define COOKIE_EXT				(COOKIE_EXT_COMMENT|COOKIE_EXT_STRING)

proc/TrimLeadingTabs(code)
	var/maxleadtabs=-1
	var/maxleadspace=-1
	var/cur=1,tlen=length(code)
	while(cur<=tlen && (maxleadtabs || maxleadspace))
		var/ch=text2ascii(code,cur)
		if(ch==13) continue
		if(ch!=10)
			var/curtabs=0,curspace=0
			while(ch==9)
				++curtabs
				if(++cur>tlen) break
				ch=text2ascii(code,cur)
			while(ch==32)
				++curspace
				if(++cur>tlen) break
				ch=text2ascii(code,cur)
			if(ch==10)
				continue
			// do not count blank lines
			if(maxleadtabs<0)
				if(!curtabs && !curspace) return code
				maxleadtabs=curtabs
				maxleadspace=curspace
			else if(curtabs<maxleadtabs)
				if(!curtabs) return code
				maxleadtabs=curtabs
				maxleadspace=0
			else if(curtabs>maxleadtabs)
				if(!maxleadtabs) return code
				maxleadspace=0
			else if(maxleadspace<0 || curspace<maxleadspace)
				maxleadspace=curspace
			cur=findtextEx(code,"\n",cur+1)
			if(!cur) break
		++cur
	if(maxleadtabs<=0 && maxleadspace<=0) return code
	maxleadtabs+=maxleadspace
	cur=1
	while(cur<=tlen)
		if(text2ascii(code,cur)==10 || text2ascii(code,cur)==13)
			++cur; continue
		code=copytext(code,1,cur)+copytext(code,cur+maxleadtabs)
		tlen-=maxleadtabs
		cur=findtextEx(code,"\n",cur)||tlen
		++cur
	return code

proc/DefaultHighlightStyles()
	.="<style>\n"
	var/list/styles=_DefaultHighlightStyles.Copy()
	var/i,j
	for(i=1,i<=args.len,i+=2)
		if(i>=args.len || !args[i]) styles-=args[i]
		else styles[args[i]]=args[i+1]
	// combine like styles
	for(i=1,i<styles.len,++i)
		for(j=styles.len,j>i,--j)
			if(styles[styles[i]]==styles[styles[j]])
				styles[i]+=", "+styles[j]
				styles[styles[i]]=styles[styles[j]]
				styles.Cut(j,j+1)
	for(i in styles) .+="[i] {[styles[i]]}\n"
	.+="</style>\n"

proc/HighlightCode(code, tabsize=4, showtabs, embed)
	if(!code) return ""
	.="<pre class=code>"
	var/cookie=0
	var/iCommentCount=0
	var/iBraceCount=0

	var/list/stack=new

	var/revisit=0
	var/linebegin=1
	var/firstchar=1
	var/nIdentBegin=0
	var/nNumBegin=0
	var/nCodeBegin=1
	var/ch,ch2
	var/j=findtextEx(code,ascii2text(13))
	var/col=1
	while(j)
		code=copytext(code,1,j)+copytext(code,j+1)
		j=findtextEx(code,ascii2text(13),j)
	var/nLength=length(code)
	for(var/I=1,I<=nLength+1,++I)
		if(!(I%25)) sleep(0)
		if(I>nLength) ch=10
		else ch=text2ascii(code,I)
		if(linebegin)
			firstchar=((cookie&~COOKIE_EXT)==0)
			linebegin=0
		if(ch==10)
			if(cookie)
				var/oldcookie=cookie
				if(nCodeBegin)
					.+=html_encode(copytext(code,nCodeBegin,I))
					nCodeBegin=0
				while(stack.len && !(cookie&COOKIE_EXT))
					cookie=stack[stack.len]
					--stack.len
					if(cookie&COOKIE_BRACE)
						iBraceCount=stack[stack.len]
						--stack.len
				cookie &= COOKIE_EXT
				if(!cookie && !(oldcookie&COOKIE_BRACE) && (embed || !stack.len))
					.+="</span>"
			iBraceCount=0
			linebegin=1
			if(nIdentBegin || nNumBegin)
				revisit=1; goto endident
			if(nCodeBegin)
				.+=html_encode(copytext(code,nCodeBegin,I))
				nCodeBegin=0
			col=I
			.+="\n"
			continue

		if(!nCodeBegin) nCodeBegin=I

		if(ch<=32)
			if(nIdentBegin || nNumBegin)
				revisit=1; goto endident
			if(ch==9)
				if(nCodeBegin<I)
					.+=html_encode(copytext(code,nCodeBegin,I))
				if(showtabs) .+="&raquo;"
				else .+=" "
				for(j=col-(tabsize-(I-col)%tabsize)%tabsize,col>j,--col) .+=" "
				nCodeBegin=0
			continue

		if(ch==92)
			if(cookie & (COOKIE_COMMENT | COOKIE_EXT_COMMENT))
				continue
			if(I==nLength) continue
			if(text2ascii(code,I+1)==10)
				++I
				col=I
			else
				if(nIdentBegin || nNumBegin)
					revisit=1; goto endident
				++col
				ch=text2ascii(code,++I)
				if(ch==9)
					if(nCodeBegin<I)
						.+=html_encode(copytext(code,nCodeBegin,I))
					if(showtabs) .+="&raquo;"
					else .+=" "
					for(j=col-(tabsize-(I-col)%tabsize)%tabsize,col>j,--col) .+=" "
					nCodeBegin=0
			continue

		if(cookie)
			if(cookie & COOKIE_COMMENT)
				continue

			//	Extended comment /*...*/
			if(cookie & COOKIE_EXT_COMMENT)
				if(I<nLength)
					if(ch==47)
						if(text2ascii(code,I+1)==42)
							++iCommentCount
							++I
					else if(ch==42)
						if(text2ascii(code,I+1)==47)
							++I
							if(--iCommentCount<=0)
								.+=html_encode(copytext(code,nCodeBegin,I+1))
								nCodeBegin=0
								iCommentCount=0	// should always be zero, but play it safe
								cookie &= ~COOKIE_EXT_COMMENT
								.+="</span>"
				continue

			//  Brace inside string '[]'
			if(cookie & COOKIE_BRACE)
				// new brace
				if(ch==91)
					if(nIdentBegin || nNumBegin)
						revisit=1; goto endident
					iBraceCount++
					continue
				// end brace
				else if(ch==93)
					if(nIdentBegin || nNumBegin)
						revisit=1; goto endident
					if(--iBraceCount<=0)
						iBraceCount=0	// should always be zero, but play it safe
						.+=html_encode(copytext(code,nCodeBegin,I+1))
						nCodeBegin=0
						cookie=stack[stack.len]
						--stack.len
						if(cookie & (COOKIE_STRING | COOKIE_EXT_STRING))
							if(embed || stack.len==1)
								.+="<span class=string>"
					continue
				goto nocookie

			//	String constant "..."
			if(cookie & COOKIE_STRING)
				if(ch==91)
					.+=html_encode(copytext(code,nCodeBegin,I))
					nCodeBegin=I
					if(embed || stack.len==1)
						.+="</span>"
					stack+=cookie
					iBraceCount++
					cookie=COOKIE_BRACE
				else if(ch==34)
					.+=html_encode(copytext(code,nCodeBegin,I+1))
					nCodeBegin=0
					cookie=stack[stack.len]
					--stack.len
					if(cookie & COOKIE_BRACE)
						iBraceCount=stack[stack.len]
						--stack.len
					if(embed || !stack.len)
						.+="</span>"
				continue

			//	Extended string {"..."}
			if(cookie & COOKIE_EXT_STRING)
				if(ch==91)
					.+=html_encode(copytext(code,nCodeBegin,I))
					nCodeBegin=I
					if(embed || stack.len==1)
						.+="</span>"
					stack+=cookie
					iBraceCount++
					cookie=COOKIE_BRACE
				else if(ch==34 && I<nLength && text2ascii(code,I+1)==125)
					++I
					.+=html_encode(copytext(code,nCodeBegin,I+1))
					nCodeBegin=0
					cookie=stack[stack.len]
					--stack.len
					if(cookie & COOKIE_BRACE)
						iBraceCount=stack[stack.len]
						--stack.len
					if(embed || !stack.len)
						.+="</span>"
				continue

			//	Char constant '...'
			if(cookie & COOKIE_CHAR)
				if(ch==39)
					cookie=stack[stack.len]
					--stack.len
					.+=html_encode(copytext(code,nCodeBegin,I+1))
					nCodeBegin=0
					if(embed || !stack.len)
						.+="</span>"
				continue

			if(cookie&COOKIE_PREPROCESSOR)
				continue

		nocookie:
		//	Unmarked text: look for new symbols
		if(ch>=48 && ch<=122 && (ch<=57 || ch>=97 || (ch>=65 && ch<=90) || ch==95))
			if(!nIdentBegin && !nNumBegin)
				.+=html_encode(copytext(code,nCodeBegin,I))
				nCodeBegin=0
				if(ch>=48 && ch<=57) nNumBegin=I
				else nIdentBegin=I
			continue

		// new extended comment
		if(ch==47)
			if(nIdentBegin || nNumBegin)
				revisit=1; goto endident
			if(I<nLength)
				ch2=text2ascii(code,I+1)
				if(ch2==42)
					if(nCodeBegin<I)
						.+=html_encode(copytext(code,nCodeBegin,I))
					nCodeBegin=I++
					cookie |= COOKIE_EXT_COMMENT
					iCommentCount++
					.+="<span class=comment>"
					continue
				if(ch2==47)
					.+=html_encode(copytext(code,nCodeBegin,I))
					nCodeBegin=I
					.+="<span class=comment>"
					cookie |= COOKIE_COMMENT
					continue

		// new extended string (must come before regular string since it overlaps)
		if(ch==123)
			if(nIdentBegin || nNumBegin)
				revisit=1; goto endident
			if(I<nLength && text2ascii(code,I+1)==34)
				if(nCodeBegin<I)
					.+=html_encode(copytext(code,nCodeBegin,I))
					nCodeBegin=I
				if(cookie&COOKIE_BRACE)
					stack+=iBraceCount
					iBraceCount=0
				stack+=cookie
				cookie=COOKIE_EXT_STRING
				if(embed || stack.len==1)
					.+="<span class=string>"
			continue

		// new string
		if(ch==34)
			if(nIdentBegin || nNumBegin)
				revisit=1; goto endident
			if(nCodeBegin<I)
				.+=html_encode(copytext(code,nCodeBegin,I))
				nCodeBegin=I
			if(cookie&COOKIE_BRACE)
				stack+=iBraceCount
				iBraceCount=0
			stack+=cookie
			cookie=COOKIE_STRING
			if(embed || stack.len==1)
				.+="<span class=string>"
			continue

		// new char
		if(ch==39)
			if(nIdentBegin || nNumBegin)
				revisit=1; goto endident
			if(nCodeBegin<I)
				.+=html_encode(copytext(code,nCodeBegin,I))
				nCodeBegin=I
			stack+=cookie
			cookie=COOKIE_CHAR
			if(embed || stack.len==1)
				.+="<span class=string>"
			continue

		// new preprocessor
		if(firstchar)
			if(ch==35)
				if(nCodeBegin<I)
					.+=html_encode(copytext(code,nCodeBegin,I))
					nCodeBegin=I
				.+="<span class=preproc>"
				cookie |= COOKIE_PREPROCESSOR
				continue
			if(ch>32)
				firstchar=0

		endident:
		if(nIdentBegin)
			if(embed || !stack.len)
				if(copytext(code,nIdentBegin,I) in DMKeywordList)
					.+="<span class=keyword>"
				else
					.+="<span class=ident>"
				.+=copytext(code,nIdentBegin,I)+"</span>"
			else
				.+=copytext(code,nIdentBegin,I)
			nIdentBegin=0
			nCodeBegin=I
		else if(nNumBegin)
			if((ch==45 || ch==43 || ch==46) \
			   && I+1<=nLength && IsDMNumber(copytext(code,nNumBegin,I+2)))
				continue
			if((embed || !stack.len) && IsDMNumber(copytext(code,nNumBegin,I)))
				.+="<span class=number>"+copytext(code,nNumBegin,I)+"</span>"
				nNumBegin=0
				nCodeBegin=I
			else
				nCodeBegin=nNumBegin
				nNumBegin=0
		if(revisit)
			--I
			revisit=0
	if(nCodeBegin) .+=html_encode(copytext(code,nCodeBegin))
	.+="</pre>"
