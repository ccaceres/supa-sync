-- Update nonexempt positions with realistic fringe benefit percentages
UPDATE nonexempt_positions
SET 
  perm_fringe_straight_time = 25,
  perm_fringe_overtime = 25,
  temp_fringe_straight_time = 10,
  temp_fringe_overtime = 10,
  perm_hiring_cost = 5000,
  updated_at = NOW()
WHERE model_id = '03ea8f9a-6921-42ba-b432-400e5f682eff'
  AND (perm_fringe_straight_time = 0 OR perm_fringe_overtime = 0);