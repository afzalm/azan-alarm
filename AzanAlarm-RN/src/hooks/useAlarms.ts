import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { alarmService } from '../services/AlarmService';
import { Alarm } from '../types';

export const useAlarms = () => {
    const queryClient = useQueryClient();

    /**
     * Get all alarms
     */
    const { data: alarms = [], isLoading, error, refetch } = useQuery({
        queryKey: ['alarms'],
        queryFn: () => alarmService.getAllAlarms(),
    });

    /**
     * Create alarm mutation
     */
    const createAlarmMutation = useMutation({
        mutationFn: (alarm: Alarm) => alarmService.scheduleAlarm(alarm),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['alarms'] });
        },
    });

    /**
     * Update alarm mutation
     */
    const updateAlarmMutation = useMutation({
        mutationFn: (alarm: Alarm) => alarmService.updateAlarm(alarm),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['alarms'] });
        },
    });

    /**
     * Delete alarm mutation
     */
    const deleteAlarmMutation = useMutation({
        mutationFn: (alarmId: string) => alarmService.cancelAlarm(alarmId),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['alarms'] });
        },
    });

    /**
     * Toggle alarm mutation
     */
    const toggleAlarmMutation = useMutation({
        mutationFn: ({ alarmId, isActive }: { alarmId: string; isActive: boolean }) =>
            alarmService.toggleAlarm(alarmId, isActive),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['alarms'] });
        },
    });

    return {
        alarms,
        isLoading,
        error,
        refetch,
        createAlarm: createAlarmMutation.mutateAsync,
        updateAlarm: updateAlarmMutation.mutateAsync,
        deleteAlarm: deleteAlarmMutation.mutateAsync,
        toggleAlarm: toggleAlarmMutation.mutateAsync,
        isCreating: createAlarmMutation.isPending,
        isUpdating: updateAlarmMutation.isPending,
        isDeleting: deleteAlarmMutation.isPending,
    };
};
