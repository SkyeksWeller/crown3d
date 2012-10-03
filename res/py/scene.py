# -*- coding: utf-8 -*-
import os
import string

scene_file_name = 'scene.txt'

def list_scene(scene_dir):
    scene_dir = string.lower(scene_dir)
    print 'list_scene: '+scene_dir
    # ����Ŀ¼
    filter_name = []
    # �����ļ�
    scene_fl = open(scene_dir + '/' + scene_file_name, 'w')
    # д���б�
    file_list = os.listdir(scene_dir)
    for each_file in file_list:
        all_file_name = scene_dir + '/' + each_file
        #print all_file_name
        is_dir = os.path.isdir(all_file_name)
        if is_dir==False:
            continue
        # ����Ŀ¼���Ƿ���map.xml�ļ�
        file_list = os.listdir(all_file_name)
        if ("map.xml" in file_list) == False:
            continue
        #����
        if each_file in filter_name:
            continue
        scene_fl.write(each_file+'\n')
        print all_file_name
    # �ر��ļ�
    scene_fl.close()

    print '\n'