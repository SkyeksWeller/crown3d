# -*- coding: utf-8 -*-
# ����������Դ�б�
import os
import string
import py.scene
import py.avatar
import py.filelist


scene_fl = None
avatar_fl = None

def main():
    curdir = os.path.abspath('.')
    print curdir
	
	# ���ɳ����б��ļ�
    py.scene.list_scene(curdir+'/scene')
    # ����avatar�б��ļ�
    py.avatar.list_avatar(curdir+'/character')
    # �����ļ��б�
    py.filelist.list_files(curdir)

if __name__ == '__main__':
    main()