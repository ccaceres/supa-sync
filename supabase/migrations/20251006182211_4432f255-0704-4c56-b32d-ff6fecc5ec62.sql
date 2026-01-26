-- Enable realtime updates for geographic_data_syncs table
ALTER TABLE public.geographic_data_syncs REPLICA IDENTITY FULL;

-- Add table to realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.geographic_data_syncs;