'use client';

import React from 'react';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import { Phone, Mail, MapPin, CheckCircle2, XCircle } from 'lucide-react';

export default function EmpleadosPage() {
  const { state } = useApp();
  const { users, projectStaff, projects } = state;

  const employees = users.filter(u => u.role !== 'cliente');

  const getAssignments = (userId: string) => {
    return projectStaff
      .filter(ps => ps.userId === userId)
      .map(ps => ({
        ...ps,
        project: projects.find(p => p.id === ps.projectId),
      }));
  };

  const roleLabels: Record<string, string> = {
    admin: 'Administrador',
    supervisor: 'Supervisor',
    empleado: 'Empleado',
  };

  const roleColors: Record<string, string> = {
    admin: 'bg-purple-100 text-purple-700',
    supervisor: 'bg-blue-100 text-blue-700',
    empleado: 'bg-gray-100 text-gray-600',
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Empleados</h1>
        <p className="text-gray-500 text-sm mt-1">{employees.length} personas en el equipo</p>
      </div>

      {/* Who is Where */}
      <Card>
        <div className="px-4 py-3 border-b border-gray-100">
          <h3 className="font-semibold text-gray-900 flex items-center gap-2">
            <MapPin className="w-4 h-4 text-blue-500" />
            Quién está dónde hoy
          </h3>
        </div>
        <CardContent>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {employees.map(user => {
              const assignments = getAssignments(user.id);
              const checkedIn = assignments.find(a => a.checkedIn);
              return (
                <div key={user.id} className={`p-3 rounded-lg border ${checkedIn ? 'border-green-200 bg-green-50' : 'border-gray-100'}`}>
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center font-semibold text-sm ${
                      checkedIn ? 'bg-green-200 text-green-700' : 'bg-gray-200 text-gray-600'
                    }`}>
                      {user.name.split(' ').map(n => n[0]).join('')}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900">{user.name}</p>
                      {checkedIn ? (
                        <p className="text-xs text-green-600 truncate flex items-center gap-1">
                          <CheckCircle2 className="w-3 h-3" />
                          {checkedIn.project?.name} · {checkedIn.checkInTime}
                        </p>
                      ) : (
                        <p className="text-xs text-gray-400">Sin check-in hoy</p>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Employee List */}
      <div className="space-y-3">
        {employees.map(user => {
          const assignments = getAssignments(user.id);
          return (
            <Card key={user.id}>
              <CardContent className="flex items-center justify-between flex-wrap gap-3">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-primary-200 rounded-full flex items-center justify-center text-primary-700 font-semibold">
                    {user.name.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <p className="font-medium text-gray-900">{user.name}</p>
                      <Badge className={roleColors[user.role]}>{roleLabels[user.role]}</Badge>
                      {user.available ? (
                        <Badge className="bg-green-100 text-green-700">Disponible</Badge>
                      ) : (
                        <Badge className="bg-red-100 text-red-700">No disponible</Badge>
                      )}
                    </div>
                    <div className="flex items-center gap-4 mt-1 text-xs text-gray-500">
                      <span className="flex items-center gap-1"><Phone className="w-3 h-3" />{user.phone}</span>
                      <span className="flex items-center gap-1"><Mail className="w-3 h-3" />{user.email}</span>
                    </div>
                    {assignments.length > 0 && (
                      <div className="flex gap-1 mt-2 flex-wrap">
                        {assignments.map(a => (
                          <span key={a.projectId} className="text-xs bg-blue-50 text-blue-600 px-2 py-0.5 rounded-full">
                            {a.project?.name}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
