# -*- coding: utf-8 -*-
import os
import string

avatar_file_name = 'avatar.txt'


# ����avatar�б�
def list_avatar(avatar_dir):
    avatar_dir = string.lower(avatar_dir)
    print 'list_avatar: '+avatar_dir
    # �����ļ�
    avatar_fl = open(avatar_dir + '/' + avatar_file_name, 'w')
    # д�б�
    filter_name = []
    file_list = os.listdir(avatar_dir)
    for each_file in file_list:
        all_file_name = avatar_dir + '/' + each_file
        #print all_file_name
        is_dir = os.path.isdir(all_file_name)
        if is_dir==False:
            continue
        if each_file in filter_name:
            continue
        avatar_fl.write(each_file+'\n')
        print all_file_name
    # �ر��ļ�
    avatar_fl.close()

    print '\n'