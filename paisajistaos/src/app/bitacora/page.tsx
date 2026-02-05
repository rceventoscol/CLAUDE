'use client';

import React, { useState } from 'react';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import { Camera, Filter } from 'lucide-react';
import { formatDateTime, tagColor } from '@/lib/utils';
import { MediaTag } from '@/types';

const ALL_TAGS: MediaTag[] = ['antes', 'durante', 'después', 'riego', 'poda', 'plagas', 'instalación', 'siembra', 'general'];

export default function BitacoraPage() {
  const { state } = useApp();
  const { logMedia, projects, users } = state;
  const [filterProject, setFilterProject] = useState<string>('todos');
  const [filterTag, setFilterTag] = useState<MediaTag | 'todos'>('todos');

  let filtered = [...logMedia].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  if (filterProject !== 'todos') filtered = filtered.filter(m => m.projectId === filterProject);
  if (filterTag !== 'todos') filtered = filtered.filter(m => m.tags.includes(filterTag));

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Bitácora Visual</h1>
        <p className="text-gray-500 text-sm mt-1">Timeline de evidencias fotográficas</p>
      </div>

      <div className="flex items-center gap-2 flex-wrap">
        <Filter className="w-4 h-4 text-gray-400" />
        <select
          className="text-sm border rounded-lg px-3 py-1.5"
          value={filterProject}
          onChange={(e) => setFilterProject(e.target.value)}
        >
          <option value="todos">Todos los proyectos</option>
          {projects.map(p => (
            <option key={p.id} value={p.id}>{p.name}</option>
          ))}
        </select>
        {ALL_TAGS.map(tag => (
          <button
            key={tag}
            onClick={() => setFilterTag(filterTag === tag ? 'todos' : tag)}
            className={`px-3 py-1 rounded-full text-xs font-medium ${
              filterTag === tag ? 'bg-primary-600 text-white' : tagColor(tag)
            }`}
          >
            {tag}
          </button>
        ))}
      </div>

      <div className="relative">
        <div className="absolute left-6 top-0 bottom-0 w-0.5 bg-gray-200" />
        <div className="space-y-6">
          {filtered.map(media => {
            const project = projects.find(p => p.id === media.projectId);
            const author = users.find(u => u.id === media.createdBy);
            return (
              <div key={media.id} className="relative pl-14">
                <div className="absolute left-4 w-4 h-4 bg-primary-500 rounded-full border-2 border-white shadow" />
                <Card>
                  <CardContent>
                    <div className="flex gap-4 flex-col sm:flex-row">
                      <div className="w-full sm:w-32 h-32 bg-gradient-to-br from-primary-200 to-primary-400 rounded-lg flex items-center justify-center text-white flex-shrink-0">
                        <Camera className="w-10 h-10" />
                      </div>
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">{media.caption}</p>
                        <div className="flex items-center gap-2 mt-1 text-xs text-gray-500 flex-wrap">
                          <span>{formatDateTime(media.createdAt)}</span>
                          <span>·</span>
                          <span className="text-primary-600">{project?.name}</span>
                          {author && <><span>·</span><span>{author.name}</span></>}
                        </div>
                        <div className="flex gap-1 mt-2 flex-wrap">
                          {media.tags.map(tag => (
                            <Badge key={tag} className={tagColor(tag)}>{tag}</Badge>
                          ))}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
