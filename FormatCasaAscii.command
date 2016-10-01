#!/usr/bin/env python3

import os, ntpath, re
import tkinter as tk
import tkinter.filedialog, tkinter.constants

class FormatCasaAscii(tk.Frame):

	def askopenfile(self):
		"""Returns an opened file in read mode"""
		return tk.filedialog.askopenfile(mode='r', **self.file_opt)

	def load_vamas_ascii(self):
		descfilename = "/Users/pakpoomb/Documents/Caltech/Lewis Group/XPS/Nb/Nb.TXT"
		with open(descfilename) as descfile:
			filename_old = ""
			filename_new = ""
			filedict = {}
			c = 1
			for line in descfile:
				line = line.rstrip()
				print(line)
				if (c % 4) == 1:
					filename_old = ntpath.basename(line)
				if (c % 4) == 2:
					find = re.compile(r"^(.*)\/.*")
					m = re.search(find, line)
					filename_new = m.group(1) if not (m is None) else line
					filename_new = re.sub('[^A-Za-z0-9]+', '', filename_new)

				if (c % 4) == 0:
					filedict[filename_old] = filename_new

				c += 1

			print(filedict)

		return

	def __init__(self, root):
		tk.Frame.__init__(self,root)
		self.load_vamas_ascii()
		button_opt = {'fill': tk.constants.BOTH, 'padx': 5, 'pady': 5}
		#tk.Button(self, text='Open description file', command=self.askopenfile).pack(**button_opt)
		tk.Button(self, text='Open description file', command=self.load_vamas_ascii).pack(**button_opt)
		
		# define options for opening a file
		self.file_opt = options = {}
		options['defaultextension'] = '.txt'
		options['filetypes'] = [('all files', '.*'), ('text files', '.txt')]
		options['parent'] = root
		options['title'] = 'Choose the main file'

def center(toplevel):
	toplevel.update_idletasks()
	w = toplevel.winfo_screenwidth()
	h = toplevel.winfo_screenheight()
	size = (w/4, h/4)
	#size = tuple(int(_) for _ in toplevel.geometry().split('+')[0].split('x'))
	x = w/2 - size[0]/2
	y = h/2 - size[1]/2
	toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

if __name__=='__main__':
	root = tk.Tk()
	FormatCasaAscii(root).pack()
	center(root)
	root.title("FormatCasaAscii")
	root.lift()
	os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
	root.mainloop()
