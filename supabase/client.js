// ============================================================================
// StoryPlay — Supabase client (client.js)
// ----------------------------------------------------------------------------
// IMPORTANT — SECRETS:
//   * Is file me koi key/password NAHI hai.
//   * Sirf SUPABASE_URL aur SUPABASE_ANON_KEY environment variables se aate hain.
//   * service_role key ko KABHI client code / app / GitHub me mat daalo.
//     service_role key sirf server-side kaam ke liye hoti hai aur wo RLS ko
//     bypass kar deti hai — uska leak matlab poora database khula hua.
//   * Anon key public client key hai (RLS policies hi asli protection hain),
//     phir bhi use hardcode karne ki bajaye env var se lo.
// ----------------------------------------------------------------------------
// Install: npm install @supabase/supabase-js
// Usage (Node / bundler):
//   import { getLiveStories, getStoryTree, getSettings } from './supabase/client.js';
// ============================================================================

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error(
    'Supabase connected nahi hai: SUPABASE_URL aur SUPABASE_ANON_KEY env vars set karo. ' +
      'Ye README_HINDI.md ke Step (d)-(e) me milenge. Koi key is file me hardcode mat karo.'
  );
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

/**
 * LIVE stories lao — Home ke All Stories ke liye.
 * RLS ki wajah se anon users ko sirf is_live = true stories dikhti hain.
 * @returns {Promise<Array>} stories (id, title, description, cover_image, category, is_mature, is_featured, start_node_id)
 */
export async function getLiveStories() {
  const { data, error } = await supabase
    .from('stories')
    .select('id, title, description, cover_image, category, is_mature, is_featured, start_node_id')
    .eq('is_live', true)
    .order('created_at', { ascending: true });

  if (error) throw error;
  return data ?? [];
}

/**
 * Ek story ka poora branching tree lao: nodes + choices.
 * video_url NULL ho to player me "Video Clip: Upload Pending" dikhao —
 * poster ko real video mat batao.
 * @param {string} storyId - story UUID
 * @returns {Promise<{story: object, nodes: Array, choices: Array}>}
 */
export async function getStoryTree(storyId) {
  const [{ data: story, error: storyError }, { data: nodes, error: nodesError }, { data: choices, error: choicesError }] =
    await Promise.all([
      supabase.from('stories').select('*').eq('id', storyId).single(),
      supabase
        .from('video_nodes')
        .select('id, story_id, node_name, video_url, trigger_timestamp_seconds, is_ending, ending_name, sort_order')
        .eq('story_id', storyId)
        .order('sort_order', { ascending: true }),
      supabase
        .from('choices')
        .select('id, source_node_id, choice_label, target_node_id')
        .in(
          'source_node_id',
          (nodes ?? []).map((n) => n.id)
        ),
    ]);

  if (storyError) throw storyError;
  if (nodesError) throw nodesError;
  if (choicesError) throw choicesError;

  return { story, nodes: nodes ?? [], choices: choices ?? [] };
}

/**
 * App settings lao (free episodes, coin cost, ad reward, VIP plans, banner).
 * @returns {Promise<Object>} e.g. { free_episodes: 5, coin_cost: 5, ad_reward: 30, vip_plans: [...], app_banner: {...} }
 */
export async function getSettings() {
  const { data, error } = await supabase.from('app_settings').select('key, value');

  if (error) throw error;
  return Object.fromEntries((data ?? []).map((row) => [row.key, row.value]));
}
